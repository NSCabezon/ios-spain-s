import Foundation
import SANLegacyLibrary
import CoreFoundationLib

protocol TransferOperativeData: SelectorTransferOperativeData, SubtypeTransferOperativeData, ConfirmationTransferOperativeData {}

enum OnePayTransferSubType {
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
    
    static func from(_ dto: TransfersType) -> OnePayTransferType {
        switch dto {
        case .INTERNATIONAL_SEPA: return .sepa
        case .INTERNATIONAL_NO_SEPA: return .noSepa
        case .NATIONAL_SEPA: return .national
        }
    }
    var accessibilityIdentifier: String? {
        return self.rawValue
    }
}

enum OnePayTransferSummaryState {
    case success
    case pending
    case error
}

protocol SubtypeTransferOperativeData: OperativeParameter {
    var maxImmediateNationalAmount: Amount? { get }
    var subType: OnePayTransferSubType? { get set }
    var type: OnePayTransferType? { get }
    var time: OnePayTransferTime? { get }
    var account: Account? { get }
    var amount: Amount? { get }
    var iban: IBAN? { get }
    var beneficiary: String? { get }
    var concept: String? { get }
    var faqs: [FaqsEntity]? { get }
    var commission: Amount? { get set }
    var isBiometryEnabled: Bool { get }
    var isTouchIdEnabled: Bool { get }
}

extension OnePayTransferSubType: CustomStringConvertible {
    var description: String {
        switch self {
        case .standard: return "summary_label_standar"
        case .immediate: return "summary_label_immediate"
        case .urgent: return "summary_label_express"
        }
    }
    
    var string: String {
        switch self {
        case .standard: return "standard"
        case .immediate: return "immediate"
        case .urgent: return "urgent"
        }
    }
}

protocol ConfirmationTransferOperativeData: OperativeParameter {
    var account: Account? { get }
    var type: OnePayTransferType? { get }
    var subType: OnePayTransferSubType? { get }
    var time: OnePayTransferTime? { get }
    var currency: SepaCurrencyInfo? { get }
    var country: SepaCountryInfo? { get }
    var iban: IBAN? { get }
    var concept: String? { get }
    var issueDate: Date? { get }
    var bankChargeAmount: Amount? { get }
    var expensesAmount: Amount? { get }
    var netAmount: Amount? { get }
    var transferAmount: Amount? { get }
    var name: String? { get }
    var beneficiaryMail: String? { get set }
    var faqs: [FaqsEntity]? { get }
    var isModifyOriginAccountEnabled: Bool { get }
    var isModifyTransferTypeEnabled: Bool { get }
    var isModifyDestinationAccountEnabled: Bool { get }
    var isModifyCountryEnabled: Bool { get }
    var isModifyPeriodicityEnabled: Bool { get }
    var isModifyConceptEnabled: Bool { get }
    var isBiometryEnabled: Bool { get }
    var isCorrectFingerFlag: Bool { get }
}

protocol SelectorTransferOperativeData: OperativeParameter {
    var account: Account? { get }
    var isBackToOriginEnabled: Bool { get }
    var list: [Account] { get }
    var listNotVisibles: [Account]? { get }
    var faqs: [FaqsEntity]? { get }
    func setAccount(_ accountEntity: AccountEntity)
}

extension ConfirmationTransferOperativeData {
    var isModifyTransferTypeEnabled: Bool {
        return self.country?.code == "ES" ? true : false
    }
}
