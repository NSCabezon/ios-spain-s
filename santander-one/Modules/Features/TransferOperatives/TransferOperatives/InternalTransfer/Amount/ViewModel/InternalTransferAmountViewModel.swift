//
//  InternalTransferAmountViewModel.swift
//  TransferOperatives
//
//  Created by Marcos Álvarez Mesa on 15/2/22.
//

import UI
import OpenCombine
import CoreDomain
import CoreFoundationLib
import Foundation

struct InternalTranferAmountLoadedInformation {
    var originAccount: AccountRepresentable
    var destinationAccount: AccountRepresentable
    var amount: String?
    var description: String?
    var issueDate: Date?
    var transferType: InternalTransferType
}

enum InternalTransferAmountState: State {
    case idle
    case loaded(InternalTranferAmountLoadedInformation)
    case didChangeAvailabilityToContinue(Bool)
    case didChangeReceiveAmount(String)
    case didChangeAmount(String)
    case didUpdateExchangeInformation(InternalTransferType)
}

final class InternalTransferAmountViewModel {
    private let dependencies: InternalTransferAmountDependenciesResolver
    private var anySubscriptions: Set<AnyCancellable> = []
    private let stateSubject = CurrentValueSubject<InternalTransferAmountState, Never>(.idle)
    var state: AnyPublisher<InternalTransferAmountState, Never>
    private lazy var modifier: InternalTransferAmountModifierProtocol = dependencies.resolve()
    private lazy var defaultCurrency: CurrencyType = NumberFormattingHandler.shared.getDefaultCurrency()
    @BindingOptional var operativeData: InternalTransferOperativeData!

    enum InternalTransferPresentableType {
        case amount(String)
        case receiveAmount(String)
        case description(String)
        case issueDate(Date)
    }

    init(dependencies: InternalTransferAmountDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }

    func viewDidLoad() {
        loadData()
        trackScreen()
    }
}

extension InternalTransferAmountViewModel {
    var progress: Progress {
        return coordinator.progress
    }

    func backToStep(_ step: InternalTransferStep) {
        coordinator.back(to: step)
    }

    func next() {
        coordinator.next()
    }

    func didSetInternalTransferPresentableType(_ type: InternalTransferPresentableType) {
        switch type {
        case .amount(let amount):
            operativeData.amount = amount.stringToDecimal?.toAmountRepresentable(with: operativeData.originAccount?.currencyRepresentable)
            calculateNewReceiveAmount()
        case .receiveAmount(let amount):
            operativeData.receiveAmount = amount.stringToDecimal?.toAmountRepresentable(with: operativeData.destinationAccount?.currencyRepresentable)
            calculateNewAmount()
        case .description(let description):
            operativeData.description = description
        case .issueDate(let date):
            operativeData.issueDate = date
        }
        dataBinding.set(operativeData)
        changeAvailabilityToContinueIfNecessary()
    }

    func updateAmountsIfNecessary() {
        stateSubject.send(.didChangeReceiveAmount(operativeData.receiveAmount?.value?.stringValue ?? ""))
        stateSubject.send(.didChangeAmount(operativeData.amount?.value?.stringValue ?? ""))
    }
}

private extension InternalTransferAmountViewModel {

    func calculateNewReceiveAmount() {
        guard let currency = self.operativeData.originAccount?.currencyRepresentable else { return }
        let receiveAmount = calculateAmount(for: operativeData.amount?.value, originCurrency: currency)
        operativeData.receiveAmount = receiveAmount?.toAmountRepresentable(with: self.operativeData.destinationAccount?.currencyRepresentable)
    }

    func calculateNewAmount() {
        guard let currency = self.operativeData.destinationAccount?.currencyRepresentable else { return }
        let newAmount = calculateAmount(for: operativeData.receiveAmount?.value, originCurrency: currency)
        operativeData.amount = newAmount?.toAmountRepresentable(with: self.operativeData.originAccount?.currencyRepresentable)
    }

    func calculateAmount(for amount: Decimal?, originCurrency: CurrencyRepresentable) -> Decimal? {
        guard let transferType = self.operativeData.transferType, let amount = amount else { return nil }
        switch transferType {
        case .noExchange:
            return nil
        case .simpleExchange(let sellExchange):
            return sellExchange.conversionRate(from: originCurrency) * amount
        case .doubleExchange(let sellExchange, let buyExchange):
            return sellExchange.conversionRate(from: originCurrency) * buyExchange.conversionRate(from: originCurrency) * amount
        }
    }

    func changeAvailabilityToContinueIfNecessary() {
        let amount: Decimal = operativeData.amount?.value ?? 0
        let isDescriptionAvailable = isDescriptionAvailable(description: operativeData.description)
        stateSubject.send(.didChangeAvailabilityToContinue(amount > 0 && isDescriptionAvailable))
    }

    func isDescriptionAvailable(description: String?) -> Bool {
        if modifier.isDescriptionRequired == true {
            return (description?.count ?? 0 > 0)
        }
        return true
    }

    func loadData() {
        let isSameCurrency = operativeData.isSameCurrency()
        resetOperativeData()
        changeAvailabilityToContinueIfNecessary()
        publishLoadedInformation()
        if !isSameCurrency {
            getExchangeRate()
        }
    }

    func resetOperativeData() {
        operativeData.transferType = getTransferType(sellRate: nil, buyRate: nil)
        operativeData.receiveAmount = nil
    }

    func publishLoadedInformation() {
        guard let originAccount = operativeData.originAccount,
              let destinationAccount = operativeData.destinationAccount,
              let transferType = self.operativeData.transferType
        else { return }
        if let inputDescriptionKey = modifier.inputDescriptionKey,
           operativeData.description == nil {
            operativeData.description = localized(inputDescriptionKey)
        }
        let loadedInformation = InternalTranferAmountLoadedInformation(
            originAccount: originAccount,
            destinationAccount: destinationAccount,
            amount: operativeData.amount?.value?.stringValue,
            description: operativeData.description,
            issueDate: operativeData.issueDate,
            transferType: transferType
        )
        stateSubject.send(.loaded(loadedInformation))
    }
    
    func getTransferType(sellRate: Decimal?, buyRate: Decimal?) -> InternalTransferType {
        guard let originCurrency = operativeData.originAccount?.currencyRepresentable,
              let destinationCurrency = operativeData.destinationAccount?.currencyRepresentable else { return .noExchange }

        let defaultCurrency = CurrencyRepresented(currencyCode: defaultCurrency.rawValue)
        let sameCurrency = operativeData.isSameCurrency()
        let containsLocalCurrency = operativeData.containsCurrency(type: self.defaultCurrency)
        switch (sameCurrency, containsLocalCurrency) {
        case (true, _):
            return .noExchange
        case (false, true):
            let currencyDifferentFromLocal = (originCurrency.currencyType != self.defaultCurrency) ? originCurrency : destinationCurrency
            return .simpleExchange(sellExchange: InternalTransferExchangeType(originCurrency: currencyDifferentFromLocal,
                                                                              destinationCurrency: defaultCurrency,
                                                                              rate: sellRate))
        case (false, false):
            return .doubleExchange(sellExchange: InternalTransferExchangeType(originCurrency: originCurrency,
                                                                              destinationCurrency: defaultCurrency,
                                                                              rate: sellRate),
                                   buyExchange: InternalTransferExchangeType(originCurrency: destinationCurrency,
                                                                             destinationCurrency: defaultCurrency,
                                                                             rate: buyRate))
        }
    }
    
    func onExchageRatesFailure() {
        coordinator.dismissJumpingGreenLoading { [weak self] in
            guard let self = self else { return }
            let internalCoordinator: InternalTransferOperativeCoordinator = self.dependencies.resolve()
            internalCoordinator.showInternalTransferError(.missingExchangeRatesResponse)
        }
    }
}

private extension InternalTransferAmountViewModel {
    var useCase: GetInternalTransferAmountExchangeRateUseCase {
        return dependencies.external.resolve()
    }
}

private extension InternalTransferAmountViewModel {
    func getExchangeRate() {
        guard let fromCurrency = operativeData.originAccount?.currencyRepresentable?.currencyType else { return }
        guard let toCurrency = operativeData.destinationAccount?.currencyRepresentable?.currencyType else { return }
        let input = GetInternalTransferAmountExchangeRateUseCaseInput(localCurrency: defaultCurrency,
                                                                      initialCurrency: fromCurrency,
                                                                      targetCurrency:  toCurrency)
        coordinator.showJumpingGreenLoadingPublisher()
            .flatMap{ self.useCase.fetchExchangeRate(input: input) }
            .flatMap(dismissLoadingPublisher)
            .subscribe(on: Schedulers.background)
            .receive(on: Schedulers.main)
            .replaceError(with: .failure)
            .eraseToAnyPublisher()
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .failure:
                    self.onExchageRatesFailure()
                case .success(let result):
                    let transferType = self.getTransferType(sellRate: result.sellRate,
                                                            buyRate: result.buyRate)
                    self.operativeData.transferType = transferType

                    self.stateSubject.send(.didUpdateExchangeInformation(transferType))
                    self.calculateNewReceiveAmount()
                    self.updateAmountsIfNecessary()
                }
            }
            .store(in: &anySubscriptions)
    }
    
    func showLoadingPublisher() -> AnyPublisher<Void, Error> {
        return coordinator.showJumpingGreenLoadingPublisher().setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func dismissLoadingPublisher(_ output: GetInternalTransferAmountExchangeRateUseCaseOutput) -> AnyPublisher<GetInternalTransferAmountExchangeRateUseCaseOutput, Error> {
        return coordinator.dismissJumpingGreenLoadingPublisher().setFailureType(to: Error.self)
            .flatMap { Just(output) }
            .eraseToAnyPublisher()
    }
}

extension InternalTransferAmountViewModel: DataBindable {
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
}

private extension InternalTransferAmountViewModel {
    var coordinator: InternalTransferOperativeCoordinator {
        return dependencies.resolve()
    }
}

// MARK: Analytics
extension InternalTransferAmountViewModel: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }
    
    var trackerPage: InternalTransferAccountAmountPage {
        InternalTransferAccountAmountPage()
    }
}

// MARK: - Decimal extension
private extension Decimal {
    private static var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.roundingMode = .floor
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = " "
        return formatter
    }

    var significantFractionalDecimalDigits: Int {
        return max(-exponent, 0)
    }

    var stringValue: String {
        let formatter = Self.formatter
        formatter.minimumFractionDigits = self.significantFractionalDecimalDigits > 0 ? 2 : 0
        return formatter.string(for: self) ?? ""
    }
}

// MARK: Decimal extension
private extension Decimal {
    func toAmountRepresentable(with currency: CurrencyRepresentable?) -> AmountRepresentable? {
        guard let destinationCurrency = currency else { return nil }
        return AmountRepresented(value: self, currencyRepresentable: destinationCurrency)
    }
}
