//
//  SendMoneyUseCaseProvider.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 30/07/2021.
//

import SANLegacyLibrary
import CoreFoundationLib
import Operative
import CoreDomain

public protocol SendMoneyUseCaseProviderProtocol: AnyObject {
    func getIbanValidationUseCase() -> IbanValidationSendMoneyUseCaseProtocol?
    func getValidateTransferUseCase(input: ValidateSendMoneyUseCaseInput) -> UseCase<ValidateSendMoneyUseCaseInput, ValidateSendMoneyUseCaseOkOutput, StringErrorOutput>
    func getValidateOtpUseCase(input: ConfirmNationalGenericSendMoneyInput) -> UseCase<ConfirmNationalGenericSendMoneyInput, ConfirmNationalGenericSendMoneyOkOutput, GenericErrorSignatureErrorOutput>
    func getSpecialPricesUseCase() -> SendMoneyTransferTypeUseCaseProtocol?
    func getConfirmSendMoneyUseCase(input: ConfirmOtpSendMoneyUseCaseInput) -> UseCase<ConfirmOtpSendMoneyUseCaseInput, ConfirmOtpSendMoneyUseCaseOkOutput, GenericErrorOTPErrorOutput>
    func getTransferTypeUseCase(input: DestinationTypeSendMoneyTransferUseCaseInput) -> UseCase<DestinationTypeSendMoneyTransferUseCaseInput, DestinationTypeSendMoneyTransferUseCaseOkOutput, StringErrorOutput>
    func getTransferTypeValidationUseCase(input: TransferTypeValidationUseCaseInput) -> UseCase<TransferTypeValidationUseCaseInput, TransferTypeValidationUseCaseOkOutput, StringErrorOutput>
    func getCheckStatusUseCase() -> CheckStatusSendMoneyTransferUseCaseProtocol?
    func getFundableTypeUseCase() -> LoadFundableTypeUseCaseProtocol?
    func getDestinationUseCase() -> SendMoneyDestinationUseCaseProtocol
    func getAmountUseCase() -> SendMoneyAmountUseCaseProtocol
    func getConfirmationUseCase() -> SendMoneyConfirmationUseCaseProtocol
    func getAmountNoSepaUseCase() -> SendMoneyAmountNoSepaUseCaseProtocol
    func getNoSepaFeesUseCase() -> SendMoneyGetFeesUseCaseProtocol
    func getConfirmationNoSepaUseCase() -> SendMoneyConfirmationNoSepaUseCaseProtocol
    func getValidateOtpNoSepaUseCase() -> ValidateOTPNoSepaUseCaseProtocol
    func getConfirmSendMoneyNoSepaUseCase() -> ConfirmSendMoneyNoSepaUseCaseProtocol
}

public final class SendMoneyUseCaseProvider: SendMoneyUseCaseProviderProtocol, ValidateSendMoneyProtocol {
    public var dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func getIbanValidationUseCase() -> IbanValidationSendMoneyUseCaseProtocol? {
        return self.dependenciesResolver.resolve(firstTypeOf: IbanValidationSendMoneyUseCaseProtocol.self)
    }
    
    public func getValidateTransferUseCase(input: ValidateSendMoneyUseCaseInput) -> UseCase<ValidateSendMoneyUseCaseInput, ValidateSendMoneyUseCaseOkOutput, StringErrorOutput> {
        guard case .now = input.time else {
            return self.dependenciesResolver.resolve(firstTypeOf: ValidateScheduledSendMoneyUseCaseProtocol.self).setRequestValues(requestValues: input)
        }
        return self.dependenciesResolver.resolve(firstTypeOf: ValidateGenericSendMoneyUseCaseProtocol.self).setRequestValues(requestValues: input)
    }
    
    public func getValidateOtpUseCase(input: ConfirmNationalGenericSendMoneyInput) -> UseCase<ConfirmNationalGenericSendMoneyInput, ConfirmNationalGenericSendMoneyOkOutput, GenericErrorSignatureErrorOutput> {
        guard input.time == .now else {
            return ValidateOTPScheduledSendMoneyUseCase(dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
        }
        return ValidateOTPGenericSendMoneyUseCase(dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    public func getSpecialPricesUseCase() -> SendMoneyTransferTypeUseCaseProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: SendMoneyTransferTypeUseCaseProtocol.self)
    }
    
    public func getConfirmSendMoneyUseCase(input: ConfirmOtpSendMoneyUseCaseInput) -> UseCase<ConfirmOtpSendMoneyUseCaseInput, ConfirmOtpSendMoneyUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        guard case .now = input.time else {
            return self.dependenciesResolver.resolve(firstTypeOf: ConfirmScheduledSendMoneyUseCaseProtocol.self).setRequestValues(requestValues: input)
        }
        return self.dependenciesResolver.resolve(firstTypeOf: ConfirmGenericSendMoneyUseCaseProtocol.self).setRequestValues(requestValues: input)
    }
    
    public func getTransferTypeUseCase(input: DestinationTypeSendMoneyTransferUseCaseInput) -> UseCase<DestinationTypeSendMoneyTransferUseCaseInput, DestinationTypeSendMoneyTransferUseCaseOkOutput, StringErrorOutput> {
        return DestinationTypeSendMoneyTransferUseCase(dependenciesResolver: self.dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    public func getTransferTypeValidationUseCase(input: TransferTypeValidationUseCaseInput) -> UseCase<TransferTypeValidationUseCaseInput, TransferTypeValidationUseCaseOkOutput, StringErrorOutput> {
        return TransferTypeValidationUseCase(dependenciesResolver: self.dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    public func getCheckStatusUseCase() -> CheckStatusSendMoneyTransferUseCaseProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: CheckStatusSendMoneyTransferUseCaseProtocol.self)
    }
    
    public func getFundableTypeUseCase() -> LoadFundableTypeUseCaseProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: LoadFundableTypeUseCaseProtocol.self)
    }
    
    public func getDestinationUseCase() -> SendMoneyDestinationUseCaseProtocol {
        return self.dependenciesResolver.resolve(firstTypeOf: SendMoneyDestinationUseCaseProtocol.self)
    }
    public func getAmountUseCase() -> SendMoneyAmountUseCaseProtocol {
        return self.dependenciesResolver.resolve(firstTypeOf: SendMoneyAmountUseCaseProtocol.self)
    }
    public func getConfirmationUseCase() -> SendMoneyConfirmationUseCaseProtocol {
        return self.dependenciesResolver.resolve(firstTypeOf: SendMoneyConfirmationUseCaseProtocol.self)
    }
    public func getAmountNoSepaUseCase() -> SendMoneyAmountNoSepaUseCaseProtocol {
        return self.dependenciesResolver.resolve(firstTypeOf: SendMoneyAmountNoSepaUseCaseProtocol.self)
    }
    public func getNoSepaFeesUseCase() -> SendMoneyGetFeesUseCaseProtocol {
        return self.dependenciesResolver.resolve(firstTypeOf: SendMoneyGetFeesUseCaseProtocol.self)
    }
    public func getConfirmationNoSepaUseCase() -> SendMoneyConfirmationNoSepaUseCaseProtocol {
        return self.dependenciesResolver.resolve(firstTypeOf: SendMoneyConfirmationNoSepaUseCaseProtocol.self)
    }
    public func getValidateOtpNoSepaUseCase() -> ValidateOTPNoSepaUseCaseProtocol {
        return self.dependenciesResolver.resolve(firstTypeOf: ValidateOTPNoSepaUseCaseProtocol.self)
    }
    public func getConfirmSendMoneyNoSepaUseCase() -> ConfirmSendMoneyNoSepaUseCaseProtocol {
        return self.dependenciesResolver.resolve(firstTypeOf: ConfirmSendMoneyNoSepaUseCaseProtocol.self)
    }
}

public enum DestinationAccountSendMoneyError {
    case ibanInvalid
    case noToName
    case noAlias
    case duplicateIban
    case duplicateAlias
    case serviceError(errorDesc: String?)
}

public final class DestinationAccountSendMoneyUseCaseErrorOutput: StringErrorOutput {
    let error: DestinationAccountSendMoneyError
    
    public init(_ error: DestinationAccountSendMoneyError) {
        self.error = error
        super.init("")
    }
}

public protocol ValidateNationalGenericSendMoneyUseCaseProtocol {
    func validateGenericTransfer(originAccount: AccountRepresentable, nationalTransferInput: SendMoneyGenericTransferInput) throws -> Result<ValidateAccountTransferRepresentable, Error>
}

public enum OnePayTransferSubType {
    case standard
    case immediate
    case urgent
    
    var trackerDescription: String {
        switch self {
        case .standard: return "estandar"
        case .immediate: return "inmediata"
        case .urgent: return "urgente"
        }
    }
}

public enum OnePayTransferType: String {
    case national
    case sepa
    case noSepa
    
    public static func from(_ dto: TransfersType) -> OnePayTransferType {
        switch dto {
        case .INTERNATIONAL_SEPA: return .sepa
        case .INTERNATIONAL_NO_SEPA: return .noSepa
        case .NATIONAL_SEPA: return .national
        }
    }
    var accessibilityIdentifier: String? {
        return self.rawValue
    }
    
    public var trackerName: String {
        switch self {
        case .national:
            return "NATIONAL"
        case .sepa:
            return "SEPA"
        case .noSepa:
            return "NO SEPA"
        }
    }
}

protocol IBANValidable {
    var iban: String? { get }
    var country: CurrencyInfoRepresentable { get }
}

extension ValidateSendMoneyUseCaseOkOutput: ValidateTransferUseCaseOkOutput {}

protocol ValidateTransferUseCaseOkOutput {
    var beneficiaryMail: String? { get }
    var scaEntity: SCAEntity? { get }
}

public final class ValidateTransferUseCaseErrorOutput: StringErrorOutput {
    let error: ValidateTransferError
    
    public init(_ error: ValidateTransferError) {
        self.error = error
        super.init("")
    }
}

public enum ValidateTransferError {
    case invalidEmail
    case serviceError(errorDesc: String?)
}


public protocol NationalSepaValidationModifierProtocol {
    func validateGenericTransfer(originAccount: AccountRepresentable, nationalTransferInput: SendMoneyGenericTransferInput) throws -> Result<ValidateAccountTransferRepresentable, Error>
}

public protocol NoSepaValidationModifierProtocol {
    func validateNoSEPATransfer(noSepaTransferInput: SendMoneyNoSEPAInput, validationSwift: ValidationSwiftRepresentable?) throws -> Result<ValidationIntNoSepaRepresentable, Error>
}

public protocol CheckStatusSendMoneyTransferUseCaseProtocol: UseCase<CheckStatusSendMoneyTransferUseCaseInput, CheckStatusSendMoneyTransferUseCaseOkOutputProtocol, StringErrorOutput> {
    func isImmediateTransfer(type: String) -> Bool
}

public protocol LoadFundableTypeUseCaseProtocol: UseCase<LoadFundableTypeUseCaseInput, LoadFundableTypeUseCaseOkOutput, StringErrorOutput> {}

public struct LoadFundableTypeUseCaseInput {
    public let amount: AmountRepresentable?
}

public struct LoadFundableTypeUseCaseOkOutput {
    public let fundableType: AccountEasyPayFundableType?
    public init(fundableType: AccountEasyPayFundableType?) {
        self.fundableType = fundableType
    }
}

public struct CheckStatusSendMoneyTransferUseCaseInput {
    public let transferConfirmAccount: TransferConfirmAccountRepresentable
}
public protocol CheckStatusSendMoneyTransferUseCaseOkOutputProtocol {
    var status: SendMoneyTransferSummaryState { get }
}

enum IBANValidationResult {
    case ok(IBANRepresentable)
    case error(DestinationAccountSendMoneyUseCaseErrorOutput)
}

public protocol ScheduledTransferRepresentableConvertible {
    var concept: String? { get }
    var saveFavorites: Bool { get }
    var alias: String? { get }
    var name: String? { get }
    var time: SendMoneyDateTypeFilledViewModel { get }
    var originAccount: AccountRepresentable { get }
    var scheduledTransfer: ValidateScheduledTransferRepresentable? { get }
    var amount: AmountRepresentable { get }
}

extension ScheduledTransferRepresentableConvertible {
    public func toSendMoneyScheduledTransferInput(date: Date, iban: IBANRepresentable, subType: String? = nil) -> SendMoneyScheduledTransferInput? {
        return SendMoneyScheduledTransferInput(ibanDestinationRepresentable: iban,
                                               amountRepresentable: self.amount,
                                               dateNextExecution: date,
                                               dateStartValidity: nil,
                                               dateEndValidity: nil,
                                               concept: self.concept,
                                               saveAsUsual: self.saveFavorites,
                                               saveAsUsualAlias: self.alias,
                                               beneficiary: self.name,
                                               transferType: subType,
                                               actuanteCompany: self.scheduledTransfer?.actuanteCompany,
                                               actuanteCode: self.scheduledTransfer?.actuanteCode,
                                               actuanteNumber: self.scheduledTransfer?.actuanteNumber,
                                               periodicity: nil,
                                               workingDayIssue: nil,
                                               nameBankIbanBeneficiary: self.scheduledTransfer?.nameBeneficiaryBank)
    }
    
    public func toSendMoneyScheduledTransferInput(startDate: Date, endDate: DateModel?, periodicity: String, workingDayIssue: String, iban: IBANRepresentable, subtype: String? = nil) -> SendMoneyScheduledTransferInput? {
        return SendMoneyScheduledTransferInput(ibanDestinationRepresentable: iban,
                                               amountRepresentable: self.amount,
                                               dateNextExecution: nil,
                                               dateStartValidity: startDate,
                                               dateEndValidity: endDate?.date,
                                               concept: self.concept,
                                               saveAsUsual: self.saveFavorites,
                                               saveAsUsualAlias: self.alias,
                                               beneficiary: self.name,
                                               transferType: subtype,
                                               actuanteCompany: self.scheduledTransfer?.actuanteCompany,
                                               actuanteCode: self.scheduledTransfer?.actuanteCode,
                                               actuanteNumber: self.scheduledTransfer?.actuanteNumber,
                                               periodicity: periodicity,
                                               workingDayIssue: workingDayIssue,
                                               nameBankIbanBeneficiary: self.scheduledTransfer?.nameBeneficiaryBank)
    }
}
