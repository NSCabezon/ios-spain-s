//
//  SendMoneyTransferFeeTypeProtocol.swift
//  Santander
//
//  Created by David Gálvez Alonso on 8/2/22.
//

import TransferOperatives
import CoreFoundationLib
import CoreDomain
import SANLibraryV3

public protocol SendMoneyTransferFeeTypeProtocol: AnyObject {
    var dependenciesResolver: DependenciesResolver { get }
    func getTransferFeeType(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput>
}

public extension SendMoneyTransferFeeTypeProtocol {
    
    var appConfigRepository: AppConfigRepositoryProtocol {
        return dependenciesResolver.resolve()
    }
    
    func getTransferFeeType(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        guard requestValues.type == .national else {
            return try self.retrieveInternationalFees(requestValues: requestValues)
        }
        guard let destinationIban = requestValues.destinationIBANRepresentable,
              let amount = requestValues.amount
        else {
            return .error(StringErrorOutput(nil))
        }
        let instantMaxAmount = self.getInstantNationalTransfersMaxAmount()
        let transferTypeFees = self.getTransferTypeFees(requestValues: requestValues, instantMaxAmount: instantMaxAmount, amount: amount)
        let shouldShowSpecialPrices = requestValues.transferDateType == .now
        guard shouldShowSpecialPrices else {
            let outPut = SendMoneyTransferTypeUseCaseOkOutput(shouldShowSpecialPrices: shouldShowSpecialPrices, fees: transferTypeFees, instantMaxAmount: nil)
            let savedRequestValues = saveOperativeData(outPut, shouldShowSpecialPrices: shouldShowSpecialPrices, requestValues: requestValues)
            return .ok(savedRequestValues)
        }
        guard self.isEnabledNationalTransferPreLiquidations(),
              let originAccount = requestValues.selectedAccount as? AccountDTO
        else {
            let outPut = SendMoneyTransferTypeUseCaseOkOutput(shouldShowSpecialPrices: shouldShowSpecialPrices, fees: transferTypeFees, instantMaxAmount: instantMaxAmount)
            let savedRequestValues = saveOperativeData(outPut, shouldShowSpecialPrices: shouldShowSpecialPrices, requestValues: requestValues)
            return .ok(savedRequestValues)
        }
        let transfersManager = self.dependenciesResolver.resolve(for: BSANManagersProvider.self).getBsanTransfersManager()
        let response = try? transfersManager.loadTransferSubTypeCommissions(originAccount: originAccount,
                                                                            destinationAccount: self.ibanRepresentableToDTO(representable: destinationIban),
                                                                            amount: self.amountRepresentableToDTO(representable: amount),
                                                                            beneficiary: requestValues.destinationName ?? "" ,
                                                                            concept: requestValues.description ?? "")
        guard let data = try? response?.getResponseData()
        else {
            let outPut = SendMoneyTransferTypeUseCaseOkOutput(shouldShowSpecialPrices: shouldShowSpecialPrices, fees: transferTypeFees, instantMaxAmount: instantMaxAmount)
            let savedRequestValues = saveOperativeData(outPut, shouldShowSpecialPrices: shouldShowSpecialPrices, requestValues: requestValues)
            return .ok(savedRequestValues)
        }
        self.fill(transferTypes: transferTypeFees, with: data.commissions)
        let outPut = SendMoneyTransferTypeUseCaseOkOutput(shouldShowSpecialPrices: shouldShowSpecialPrices, fees: transferTypeFees, instantMaxAmount: instantMaxAmount)
        let savedRequestValues = saveOperativeData(outPut, shouldShowSpecialPrices: shouldShowSpecialPrices, requestValues: requestValues)
        return .ok(savedRequestValues)
    }
}

private extension SendMoneyTransferFeeTypeProtocol {
    func getTransferTypeFees(requestValues: SendMoneyOperativeData, instantMaxAmount: AmountRepresentable?, amount: AmountRepresentable) -> [SendMoneyTransferTypeFee] {
        var transferTypeFees: [SendMoneyTransferTypeFee] = [SendMoneyTransferTypeFee(type: SpainTransferType.standard, fee: nil)]
        if self.isImmediateEnabled(maxAmount: instantMaxAmount, amount: amount) {
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
    
    func isUrgentTypeDisabled(requestValues: SendMoneyOperativeData) -> Bool {
        let accountDescriptorRepository: AccountDescriptorRepositoryProtocol = self.dependenciesResolver.resolve(for: AccountDescriptorRepositoryProtocol.self)
        guard let accountGroupEntities = accountDescriptorRepository.getAccountDescriptor()?.accountGroupEntities else { return false }
        return accountGroupEntities.contains(where: {$0.entityCode == requestValues.selectedAccount?.ibanRepresentable?.getEntityCode()}) && accountGroupEntities.contains(where: {$0.entityCode == requestValues.destinationIBANRepresentable?.getEntityCode()})
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
    
    func saveOperativeData(_ output: SendMoneyTransferTypeUseCaseOkOutput, shouldShowSpecialPrices: Bool, requestValues: SendMoneyOperativeData) -> SendMoneyOperativeData {
        requestValues.specialPricesOutput = output
        if !output.shouldShowSpecialPrices {
            requestValues.selectedTransferType = output.fees.first
        }
        return requestValues
    }
    
    func retrieveInternationalFees(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        switch requestValues.type {
        case .sepa: return try self.retrieveInternationalSepaFee(requestValues: requestValues)
        default: return .ok(requestValues)
        }
    }
    
    func retrieveInternationalSepaFee(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        let chargeAmount = requestValues.bankChargeAmount
        let output = SendMoneyTransferTypeUseCaseOkOutput(
            shouldShowSpecialPrices: false,
            fees: [
                SendMoneyTransferTypeFee(
                    type: SpainInternationalTransferType.standard,
                    fee: chargeAmount
                )
            ],
            instantMaxAmount: nil
        )
        return .ok(self.saveOperativeData(output, shouldShowSpecialPrices: output.shouldShowSpecialPrices, requestValues: requestValues))
    }
}
