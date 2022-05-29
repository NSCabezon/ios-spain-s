import Foundation
import CoreFoundationLib
import CoreDomain

struct AccountSearchParameters {
    var searchString: String?
    var dateRange: DateRangeSearchParameters
    var amountFrom: String?
    var amountTo: String?
    var transactionType: TransactionOperationType
    var concept: AccountConcept
    var accountEasyPay: AccountEasyPay?
}

enum TransactionOperationType {
    case all
    case checkDeposit
    case checkPayment
    case cashDeposit
    case cashPayment
    case receivedTransfer
    case issuedTransfer
    case severalDocumentCharges
    case receiptsCharges

    static var allTypes: [TransactionOperationType] {
        return [.all, .checkDeposit, .checkPayment, .cashDeposit, .cashPayment, .receivedTransfer, .issuedTransfer, .severalDocumentCharges, .receiptsCharges]
    }

    var descriptionKey: String {
        switch self {
        case .all:
            return "search_label_all"
        case .checkDeposit:
            return "search_label_depositChecks"
        case .checkPayment:
            return "search_label_payChecks"
        case .cashDeposit:
            return "search_label_depositCash"
        case .cashPayment:
            return "search_label_PayCash"
        case .receivedTransfer:
            return "search_label_receiveTransfer"
        case .issuedTransfer:
            return "search_label_sentTransfer"
        case .severalDocumentCharges:
            return "search_label_documents"
        case .receiptsCharges:
            return "search_label_bill"
        }
    }

    init(_ entity: TransactionOperationTypeEntity) {
        switch entity {
        case .checkDeposit:
            self = .checkDeposit
        case .checkPayment:
            self = .checkPayment
        case .cashDeposit:
            self = .cashDeposit
        case .cashPayment:
            self = .cashPayment
        case .receivedTransfer:
            self = .receivedTransfer
        case .issuedTransfer:
            self = .issuedTransfer
        case .severalDocumentCharges:
            self = .severalDocumentCharges
        case .receiptsCharges:
            self = .severalDocumentCharges
        case .all:
            self = .all
        }
    }
}

enum AccountConcept {
    case all
    case expense
    case income

    static var allConcepts: [AccountConcept] {
        return [.all, .expense, .income]
    }

    var descriptionKey: String {
        switch self {
        case .all:
            return "search_tab_all"
        case .expense:
            return "search_tab_expenses"
        case .income:
            return "search_tab_deposit"
        }
    }

    init(_ entity: TransactionConceptType) {
        switch entity {
        case .all:
            self = .all
        case .expenses:
            self = .expense
        case .income:
            self = .income
        }
    }
}
