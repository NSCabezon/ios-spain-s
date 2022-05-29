//
//  SendMoneyTransferTypeUseCase.swift
//  Santander
//
//  Created by Angel Abad Perez on 29/11/21.
//

import TransferOperatives
import CoreFoundationLib
import CoreDomain
import SANLibraryV3

final class SendMoneyTransferTypeUseCase: UseCase<SendMoneyTransferTypeUseCaseInputProtocol,
                                                  SendMoneyTransferTypeUseCaseOkOutputProtocol,
                                                  StringErrorOutput>,
                                          SendMoneyTransferTypeUseCaseProtocol {
    let dependenciesResolver: DependenciesResolver
    let appConfigRepository: AppConfigRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: SendMoneyTransferTypeUseCaseInputProtocol) throws -> UseCaseResponse<SendMoneyTransferTypeUseCaseOkOutputProtocol, StringErrorOutput> {
        guard let requestValues = requestValues as? SendMoneyTransferTypeUseCaseInput
        else { return .error(StringErrorOutput("Input is no conforming SendMoneyTransferTypeUseCaseInputProtocol")) }
        let instantMaxAmount = self.getInstantNationalTransfersMaxAmount()
        let transferTypeFees = self.getTransferTypeFees(requestValues: requestValues, instantMaxAmount: instantMaxAmount)
        let shouldShowSpecialPrices = requestValues.transferDateType == .now
        guard shouldShowSpecialPrices else {
            return .ok(SendMoneyTransferTypeUseCaseOkOutput(shouldShowSpecialPrices: shouldShowSpecialPrices, fees: transferTypeFees, instantMaxAmount: nil))
        }
        guard self.isEnabledNationalTransferPreLiquidations(),
              let originAccount = requestValues.sourceAccount as? AccountDTO
        else { return .ok(SendMoneyTransferTypeUseCaseOkOutput(shouldShowSpecialPrices: shouldShowSpecialPrices, fees: transferTypeFees, instantMaxAmount: instantMaxAmount)) }
        let transfersManager = self.dependenciesResolver.resolve(for: BSANManagersProvider.self).getBsanTransfersManager()
        let response = try? transfersManager.loadTransferSubTypeCommissions(originAccount: originAccount,
                                                                            destinationAccount: self.ibanRepresentableToDTO(representable: requestValues.destinationIban),
                                                                            amount: self.amountRepresentableToDTO(representable: requestValues.amount),
                                                                            beneficiary: requestValues.beneficiary,
                                                                            concept: requestValues.concept)
        guard let data = try? response?.getResponseData()
        else { return .ok(SendMoneyTransferTypeUseCaseOkOutput(shouldShowSpecialPrices: shouldShowSpecialPrices, fees: transferTypeFees, instantMaxAmount: instantMaxAmount)) }
        self.fill(transferTypes: transferTypeFees, with: data.commissions)
        return .ok(SendMoneyTransferTypeUseCaseOkOutput(shouldShowSpecialPrices: shouldShowSpecialPrices, fees: transferTypeFees, instantMaxAmount: instantMaxAmount))
    }
}

private extension SendMoneyTransferTypeUseCase {
    func getTransferTypeFees(requestValues: SendMoneyTransferTypeUseCaseInput,
                             instantMaxAmount: AmountRepresentable?) -> [SendMoneyTransferTypeFee] {
        var transferTypeFees: [SendMoneyTransferTypeFee] = [SendMoneyTransferTypeFee(type: SpainTransferType.standard, fee: nil)]
        if self.isImmediateEnabled(maxAmount: instantMaxAmount, amount: requestValues.amount) {
            transferTypeFees.append(SendMoneyTransferTypeFee(type: SpainTransferType.immediate, fee: nil))
        }
        if !self.isUrgentTypeDisabled(requestValues: requestValues) {
            transferTypeFees.append(SendMoneyTransferTypeFee(type: SpainTransferType.urgent, fee: nil))
        }
        return transferTypeFees
    }
    
    func isImmediateEnabled(maxAmount: AmountRepresentable?, amount: AmountRepresentable) -> Bool {
        guard let maxAmount = maxAmount?.value, let amount = amount.value else { return true }
        return maxAmount >= amount
    }
    
    func isUrgentTypeDisabled(requestValues: SendMoneyTransferTypeUseCaseInput) -> Bool {
        let accountDescriptorRepository: AccountDescriptorRepositoryProtocol = self.dependenciesResolver.resolve(for: AccountDescriptorRepositoryProtocol.self)
        guard let accountGroupEntities = accountDescriptorRepository.getAccountDescriptor()?.accountGroupEntities else { return false }
        return accountGroupEntities.contains(where: {$0.entityCode == requestValues.sourceAccount.ibanRepresentable?.getEntityCode()}) && accountGroupEntities.contains(where: {$0.entityCode == requestValues.destinationIban.getEntityCode()})
    }
    
    func getInstantNationalTransfersMaxAmount() -> AmountRepresentable? {
        guard let maxAmount = appConfigRepository.getDecimal(TransferConstant.appConfigInstantNationalTransfersMaxAmount)
        else { return nil }
        return AmountEntity(value: maxAmount)
    }
    
    func isEnabledNationalTransferPreLiquidations() -> Bool {
        return appConfigRepository.getBool(TransferConstant.appConfigEnableNationalTransferPreLiquidations) ?? false
    }
    
    func ibanRepresentableToDTO(representable: IBANRepresentable) -> IBANDTO {
        return IBANDTO(countryCode: representable.countryCode,
                       checkDigits: representable.checkDigits,
                       codBban: representable.codBban)
    }
    
    func amountRepresentableToDTO(representable: AmountRepresentable) -> AmountDTO {
        return AmountDTO(value: representable.value ?? .zero,
                         currency: CurrencyDTO(currencyName: representable.currencyRepresentable?.currencyName ?? "",
                                               currencyType: representable.currencyRepresentable?.currencyType ?? .eur))
    }
    
    func fill(transferTypes: [SendMoneyTransferTypeFee], with commissions: [TransferSubTypeDTO: AmountDTO?]) {
        transferTypes.forEach {
            guard let type = TransferSubTypeDTO(rawValue: ($0.type as? SpainTransferType)?.rawValue.lowercased() ?? ""),
                  let commission = commissions[type] else { return }
            $0.fee = commission
        }
    }
}

struct SendMoneyTransferTypeUseCaseInput: SendMoneyTransferTypeUseCaseInputProtocol {
    public let sourceAccount: AccountRepresentable
    public let destinationIban: IBANRepresentable
    public let amount: AmountRepresentable
    public let transferDateType: SendMoneyDateTypeViewModel
    public let beneficiary: String
    public let concept: String
}

struct SendMoneyTransferTypeUseCaseOkOutput: SendMoneyTransferTypeUseCaseOkOutputProtocol {
    var shouldShowSpecialPrices: Bool
    let fees: [SendMoneyTransferTypeFee]
    let instantMaxAmount: AmountRepresentable?
    var transactionTypeString: String? {
        return nil
    }
}

struct SendMoneyTransferTypeUseCaseInputAdapter: SendMoneyTransferTypeUseCaseInputAdapterProtocol {
    func toUseCaseInput(operativeData: SendMoneyOperativeData) -> SendMoneyTransferTypeUseCaseInputProtocol? {
        guard let selectedAccount = operativeData.selectedAccount,
              let destinationIban = operativeData.destinationIBANRepresentable,
              let transferDateType = operativeData.transferDateType,
              let amount = operativeData.amount
        else { return nil }
        return SendMoneyTransferTypeUseCaseInput(
            sourceAccount: selectedAccount,
            destinationIban: destinationIban,
            amount: amount,
            transferDateType: transferDateType,
            beneficiary: operativeData.destinationName ?? "",
            concept: operativeData.description ?? ""
        )
    }
}
