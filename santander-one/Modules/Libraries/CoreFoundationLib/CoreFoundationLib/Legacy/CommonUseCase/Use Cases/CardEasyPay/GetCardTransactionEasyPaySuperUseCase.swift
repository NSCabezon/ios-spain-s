//
//  GetCardTransactionEasyPaySuperUseCase.swift
//  CommonUseCase
//
//  Created by Juan Carlos López Robles on 7/2/20.
//

import Foundation
import SANLegacyLibrary

public protocol GetCardTransactionEasyPaySuperUseCaseDelegate: AnyObject {
    func didFinishCardTransactionEasyPaySuccessfully(with cardTransactionEasyPay: CardTransactionEasyPay)
    func didFinishCardTransactionEasyPayWithError(_ error: String?)
}

public final class GetCardTransactionEasyPayDelegateHandler: SuperUseCaseDelegate {
    var feePerMonths = [Int: EasyPayCurrentFeeDataEntity]()
    var easyPayOperativeData: EasyPayOperativeDataEntity?
    var currentAmount: Decimal = 0
    weak var delegate: GetCardTransactionEasyPaySuperUseCaseDelegate?
    
    public func onSuccess() {
        guard let easyPayOperativeData = self.easyPayOperativeData else { return }
        
        let fractionatePayment = FractionatePaymentEntity(
            fractions: getPaymentPerMonths(),
            minAmount: 60,
            maxMonths: 36
        )
        
        let cardTransactionEasyPay = CardTransactionEasyPay(
            fractionatePayment: fractionatePayment,
            easyPayOperativeData: easyPayOperativeData)
        
        self.delegate?.didFinishCardTransactionEasyPaySuccessfully(with: cardTransactionEasyPay)
    }
    
    func getPaymentPerMonths() -> [MontlyPaymentFeeEntity] {
        var paymentPerMonths = feePerMonths
            .sorted { $0.0 > $1.0 }
            .map { (months, fee) -> MontlyPaymentFeeEntity in
                return MontlyPaymentFeeEntity(fee: Decimal(fee.feeAmount ?? 0.0),
                                              numberOfMonths: months,
                                              easyPayAmortization: EasyPayAmortizationEntity(from: fee),
                                              currentAmount: currentAmount)
        }
        paymentPerMonths.append(MontlyPaymentFeeEntity())
        return paymentPerMonths
    }
    
    func clear() {
        self.feePerMonths.removeAll()
    }
    
    public func onError(error: String?) {
        self.delegate?.didFinishCardTransactionEasyPayWithError(error)
    }
}

public class GetCardTransactionEasyPaySuperUseCase: SuperUseCase<GetCardTransactionEasyPayDelegateHandler> {
    private let dependenciesResolver: DependenciesResolver
    private let handlerDelegate: GetCardTransactionEasyPayDelegateHandler
    private let minFee: Int = 2
    private let maxFee: Int = 36
    private let firstMonthFee: Decimal = 36.0
    private let secondMonthFee: Decimal = 18.0
    private var transaction: CardTransactionEntity?
    private var card: CardEntity?
    
    public weak var delegate: GetCardTransactionEasyPaySuperUseCaseDelegate? {
        get { return self.handlerDelegate.delegate }
        set { self.handlerDelegate.delegate = newValue }
    }
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.handlerDelegate = GetCardTransactionEasyPayDelegateHandler()
        let useCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        super.init(useCaseHandler: useCaseHandler, delegate: self.handlerDelegate)
    }
    
    public func requestValue(card: CardEntity, transaction: CardTransactionEntity) {
        self.card = card
        self.transaction = transaction
        self.handlerDelegate.currentAmount = abs(self.transaction?.amount?.value ?? 0)
    }
    
    public override func setupUseCases() {
        self.handlerDelegate.clear()
        guard let card = self.card, let transaction = self.transaction else { return }
        let easyPayUseCase = self.dependenciesResolver.resolve(for: GetCardEasyPayOperativeDataUseCase.self)
        let input = GetCardEasyPayOperativeDataUseCaseInput(card: card, transaction: transaction)
        let months = self.getNumberOfMonthsForQuoteCalculation(amount: self.transaction?.amount?.value,
                                                               isAllInOneCard: self.card?.isAllInOne ?? false)
        self.add(easyPayUseCase.setRequestValues(requestValues: input)) { [weak self] result in
            self?.handlerDelegate.easyPayOperativeData = result.easyPayOperativeData
            months.forEach { (month) in
                self?.validateEasyPayForMonth(month, andFeeData: result.easyPayOperativeData.feeData)
            }
        }
    }
}

private extension GetCardTransactionEasyPaySuperUseCase {
    func validateEasyPayForMonth(_ month: Int, andFeeData feeData: FeeDataEntity) {
        guard let card = self.card, let transaction = self.transaction else { return }
        let useCase = self.dependenciesResolver.resolve(for: FirstFeeInfoEasyPayUseCase.self)
        let input = EasyPayFirstFeeInfoUseCaseInput(numberOfFees: month,
                                                    cardDTO: card.dto,
                                                    transactionBalanceCode: transaction.dto.balanceCode,
                                                    transactionDay: transaction.dto.transactionDay)
        
        self.add(useCase.setRequestValues(requestValues: input)) { result in
            self.handlerDelegate.feePerMonths[month] = result.currentFeeData
        }
    }
    
    public func getNumberOfMonthsForQuoteCalculation(amount: Decimal?, isAllInOneCard: Bool) -> [Int] {
        let realAmount = abs(amount ?? 0)
        var numberOfMonths = [Int]()
        let maximumTerm = calculateMaximumTerm(amount: realAmount)
        let mediumTerm = calculateMediumTerm(maximumTerm: maximumTerm)
        numberOfMonths = [(mediumTerm as NSDecimalNumber).intValue,
                          (maximumTerm as NSDecimalNumber).intValue]
        if isAllInOneCard &&
            realAmount >= InstallmentsConstants.allInOneCardLowerLimitQuote && realAmount <= InstallmentsConstants.allInOneCardUpperLimitQuote {
            numberOfMonths[InstallmentsConstants.averageTermIndex] = InstallmentsConstants.allInOneNoInterestTerm
            if numberOfMonths[InstallmentsConstants.maximumTermIndex] == InstallmentsConstants.allInOneNoInterestTerm {
                numberOfMonths[InstallmentsConstants.maximumTermIndex] = InstallmentsConstants.minimumInstallmentsNumber
            }
        }
        return numberOfMonths
    }
    
    public func calculateMaximumTerm(amount: Decimal) -> Decimal {
        let result = Decimal(InstallmentsConstants.maximumInstallmentsNumber)
        let maximunTerm = (amount as NSDecimalNumber).dividing(by: NSDecimalNumber(decimal: InstallmentsConstants.minimumFeeAmount))
        let roundedMaximumTerm = roundedDecimalToInt(decimal: Decimal(maximunTerm.doubleValue), down: true)
        if roundedMaximumTerm > InstallmentsConstants.maximumInstallmentsNumber {
            return result
        }
        return Decimal(roundedMaximumTerm)
    }

    public func calculateMediumTerm(maximumTerm: Decimal) -> Decimal {
        let nominalMediumTerm = (maximumTerm as NSDecimalNumber).dividing(by: 2)
        let mediumTerm = roundedDecimalToInt(decimal: Decimal(nominalMediumTerm.doubleValue), down: false)
        return Decimal(mediumTerm)
    }

    
    func roundedDecimalToInt(decimal: Decimal, down: Bool) -> Int {
        let value = NSDecimalNumber(decimal: decimal)
        let doubleDecimal = abs(value.doubleValue).rounded(down ? .towardZero : .awayFromZero)
        return Int(doubleDecimal)
    }
}

public struct CardTransactionEasyPay {
    public let fractionatePayment: FractionatePaymentEntity
    public let easyPayOperativeData: EasyPayOperativeDataEntity
}
