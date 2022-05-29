import Foundation

public protocol LoanTransactionDetailConfigurationRepresentable {
    var fields: [(LoanTransactionDetailFieldRepresentable, LoanTransactionDetailFieldRepresentable?)] { get }
}

public protocol LoanTransactionDetailFieldRepresentable {
    var title: String { get }
    var titleAccessibility: String { get }
    var value: LoanTransactionDetailValueField { get }
    var valueAccessibility: String { get }
}

public enum LoanTransactionDetailValueField {
    case operationDate
    case valueDate
    case feeAmount
    case capitalAmount
    case interestsAmount
    case taxes
    case pendingCapitalAmount
    case recipientAccount
    case recipientData
}
