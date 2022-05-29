//
//  SendMoneyValidationProtocol.swift
//  Santander
//
//  Created by David Gálvez Alonso on 7/2/22.
//

import CoreFoundationLib
import TransferOperatives
import CoreDomain

public protocol SendMoneyValidationProtocol: AnyObject {
    var dependenciesResolver: DependenciesResolver { get }
    func validateTransfer(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput>
}

public extension SendMoneyValidationProtocol {
    func validateTransfer(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        switch requestValues.transferDateType {
        case .now:
            guard requestValues.type != .noSepa else {
                return .ok(requestValues)
            }
            return try self.validateGenericTransfer(requestValues: requestValues)
        case .day:
            return try self.validateDeferredTransfer(requestValues: requestValues)
        case .periodic:
            return try self.validatePeriodicTransfer(requestValues: requestValues)
        case .none:
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
    }
}

private extension SendMoneyValidationProtocol {
    
    var transferRepository: TransfersRepository {
        return dependenciesResolver.resolve()
    }
    
    func validateGenericTransfer(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        let transferType = self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)?.transferTypeFor(onePayType: requestValues.type, subtype: "")
        let genericTransferDTO = SendMoneyGenericTransferInput(
            ibanRepresentable: requestValues.destinationIBANRepresentable,
            amountRepresentable: requestValues.amount,
            concept: requestValues.description,
            beneficiary: requestValues.destinationName,
            saveAsUsual: requestValues.saveToFavorite,
            saveAsUsualAlias: requestValues.destinationAlias,
            transferType: transferType,
            beneficiaryMail: nil
        )
        let response = try self.transferRepository.validateGenericTransfer(originAccount: requestValues.selectedAccount!, nationalTransferInput: genericTransferDTO)
        switch response {
        case .success(let validate):
            guard let transferNational = validate.transferNationalRepresentable,
                  transferNational.scaRepresentable != nil else {
                return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))
            }
            requestValues.transferNationalRepresentable = transferNational
            requestValues.scaRepresentable = transferNational.scaRepresentable
            return UseCaseResponse.ok(requestValues)
        case .failure(let error):
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: error.localizedDescription)))
        }
    }
    
    func validateDeferredTransfer(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        guard case .day(date: let date) = requestValues.transferFullDateType,
              let originAcount = requestValues.selectedAccount
        else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let transferType: String? = self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)?.transferTypeFor(onePayType: requestValues.type, subtype: requestValues.selectedTransferType?.type.serviceString ?? "")
        let transferInput = SendMoneyScheduledTransferInput(ibanDestinationRepresentable: requestValues.destinationIBANRepresentable,
                                                            amountRepresentable: requestValues.amount,
                                                            dateNextExecution: date,
                                                            dateStartValidity: nil,
                                                            dateEndValidity: nil,
                                                            concept: requestValues.description,
                                                            saveAsUsual: requestValues.saveToFavorite,
                                                            saveAsUsualAlias: requestValues.destinationAlias,
                                                            beneficiary: requestValues.destinationName,
                                                            transferType: transferType,
                                                            actuanteCompany: requestValues.scheduledTransfer?.actuanteCompany,
                                                            actuanteCode: requestValues.scheduledTransfer?.actuanteCode,
                                                            actuanteNumber: requestValues.scheduledTransfer?.actuanteNumber,
                                                            periodicity: nil,
                                                            workingDayIssue: nil,
                                                            nameBankIbanBeneficiary: requestValues.scheduledTransfer?.nameBeneficiaryBank)
        let response = try transferRepository.validateDeferredTransfer(originAcount: originAcount, scheduledTransferInput: transferInput)
        switch response {
        case .success(let validate):
            guard let sca = validate.scaRepresentable else {
                return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))
            }
            requestValues.scaRepresentable = sca
            requestValues.scheduledTransfer = validate
            return UseCaseResponse.ok(requestValues)
        case .failure(let error) :
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: error.localizedDescription)))
        }
    }
    
    func validatePeriodicTransfer(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        guard case .periodic(start: let startDate, end: let endDate, periodicity: let periodicity, emission: let workingDayIssue) = requestValues.transferFullDateType else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let endDateValue: DateModel?
        switch endDate {
        case .never: endDateValue = nil
        case .date(let date): endDateValue = DateModel(date: date)
        }
        let transferType: String? = self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)?.transferTypeFor(onePayType: requestValues.type, subtype: requestValues.selectedTransferType?.type.serviceString ?? "")
        let sendMoneyModifier = self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)
        let periodicityName = sendMoneyModifier?.serviceKeyForPeriodicity(periodicity) ?? ""
        let workingDayIssueName = sendMoneyModifier?.serviceKeyForWorkingDayIssue(workingDayIssue) ?? ""
        let transferInput = SendMoneyScheduledTransferInput(ibanDestinationRepresentable: requestValues.destinationIBANRepresentable,
                                                            amountRepresentable: requestValues.amount,
                                                            dateNextExecution: nil,
                                                            dateStartValidity: startDate,
                                                            dateEndValidity: endDateValue?.date,
                                                            concept: requestValues.description,
                                                            saveAsUsual: requestValues.saveToFavorite,
                                                            saveAsUsualAlias: requestValues.destinationAlias,
                                                            beneficiary: requestValues.destinationName,
                                                            transferType: transferType,
                                                            actuanteCompany: requestValues.scheduledTransfer?.actuanteCompany,
                                                            actuanteCode: requestValues.scheduledTransfer?.actuanteCode,
                                                            actuanteNumber: requestValues.scheduledTransfer?.actuanteNumber,
                                                            periodicity: periodicityName,
                                                            workingDayIssue: workingDayIssueName,
                                                            nameBankIbanBeneficiary: requestValues.scheduledTransfer?.nameBeneficiaryBank)
        guard let originAcount = requestValues.selectedAccount
        else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let response = try transferRepository.validatePeriodicTransfer(originAcount: originAcount, scheduledTransferInput: transferInput)
        switch response {
        case .success(let validate):
            guard let sca = validate.scaRepresentable else {
                return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))
            }
            requestValues.scaRepresentable = sca
            requestValues.scheduledTransfer = validate
            return UseCaseResponse.ok(requestValues)
        case .failure(let error):
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: error.localizedDescription)))
        }
    }
}
