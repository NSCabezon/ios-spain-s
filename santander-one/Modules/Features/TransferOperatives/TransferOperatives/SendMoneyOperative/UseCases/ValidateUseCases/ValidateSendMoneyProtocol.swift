//
//  ValidateSendMoneyProtocol.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 28/07/2021.
//

import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

public protocol ValidateSendMoneyProtocol {
    var dependenciesResolver: DependenciesResolver { get }
}

extension ValidateSendMoneyProtocol {
    var bankingUtils: BankingUtilsProtocol {
        return dependenciesResolver.resolve()
    }
    
    var provider: BSANManagersProvider {
        return dependenciesResolver.resolve()
    }
    
    var transferProvider: TransfersRepository {
        return dependenciesResolver.resolve()
    }
    
    func validateScheduleType<Input: ScheduledTransferRepresentableConvertible>(requestValues: Input, iban: IBANRepresentable, subType: String? = nil) throws -> Result<ValidateScheduledTransferRepresentable, Error> {
        if case .day = requestValues.time {
            return try validateDeferredTransfer(requestValues: requestValues, iban: iban, subType: subType)
        } else if case .periodic = requestValues.time {
            return try validatePeriodicTransfer(requestValues: requestValues, iban: iban, subType: subType)
        } else {
            return .failure(StringErrorOutput(nil))
        }
    }
    
    func validateSepaTransfer(originAccount: AccountRepresentable, genericTransferDTO: SendMoneyGenericTransferInput, isConfirmationStep: Bool) throws ->  Result<ValidateAccountTransferRepresentable, Error> {
        if isConfirmationStep {
            guard let validationModifier = self.dependenciesResolver.resolve(forOptionalType: NationalSepaValidationModifierProtocol.self) else {
                return try transferProvider.validateGenericTransfer(originAccount: originAccount, nationalTransferInput: genericTransferDTO)
            }
            return try validationModifier.validateGenericTransfer(originAccount: originAccount, nationalTransferInput: genericTransferDTO)
        } else {
            return try transferProvider.validateGenericTransfer(originAccount: originAccount, nationalTransferInput: genericTransferDTO)
        }
    }

    func validatePeriodicTransfer<Input: ScheduledTransferRepresentableConvertible>(requestValues: Input, iban: IBANRepresentable, subType: String? = nil) throws -> Result<ValidateScheduledTransferRepresentable, Error> {
        guard case .periodic(start: let startDate, end: let endDate, periodicity: let periodicity, emission: let workingDayIssue) = requestValues.time else {
            return .failure(StringErrorOutput(nil))
        }
        let endDateValue: DateModel?
        switch endDate {
        case .never: endDateValue = nil
        case .date(let date): endDateValue = DateModel(date: date)
        }
        let sendMoneyModifier = self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)
        let periodicityName = sendMoneyModifier?.serviceKeyForPeriodicity(periodicity) ?? ""
        let workingDayIssueName = sendMoneyModifier?.serviceKeyForWorkingDayIssue(workingDayIssue) ?? ""
        guard let transferDTO = requestValues.toSendMoneyScheduledTransferInput(startDate: startDate, endDate: endDateValue, periodicity: periodicityName, workingDayIssue: workingDayIssueName, iban: iban, subtype: subType) else {
            return .failure(StringErrorOutput(nil))
        }
        let response = try transferProvider.validatePeriodicTransfer(originAcount: requestValues.originAccount, scheduledTransferInput: transferDTO)
        return response
    }
    
    func validateDeferredTransfer<Input: ScheduledTransferRepresentableConvertible>(requestValues: Input, iban: IBANRepresentable, subType: String? = nil) throws -> Result<ValidateScheduledTransferRepresentable, Error> {
        guard case .day(date: let date) = requestValues.time,
              let transferDTO = requestValues.toSendMoneyScheduledTransferInput(date: date, iban: iban, subType: subType) else {
            return .failure(StringErrorOutput(nil))
        }
        let response = try transferProvider.validateDeferredTransfer(originAcount: requestValues.originAccount, scheduledTransferInput: transferDTO)
        return response
    }
    
    func ibanValidation(requestValues: IBANValidable) -> IBANValidationResult {
        guard let ibanString = requestValues.iban else {
            return .error(DestinationAccountSendMoneyUseCaseErrorOutput(.ibanInvalid))
        }
        let checkDigits = bankingUtils.calculateCheckDigit(originalIBAN: ibanString)
        guard !checkDigits.isEmpty else {
            return .error(DestinationAccountSendMoneyUseCaseErrorOutput(.ibanInvalid))
        }
        return .ok(IBANDTO(ibanString: ibanString))
    }
    
    public func getTransferType(forSubtype subType: OnePayTransferSubType?) -> TransferTypeDTO {
        switch subType {
        case .immediate:
            return .NATIONAL_INSTANT_TRANSFER
        case .urgent:
            return  .NATIONAL_URGENT_TRANSFER
        case .standard, .none:
            return .NATIONAL_TRANSFER
        }
    }
}
