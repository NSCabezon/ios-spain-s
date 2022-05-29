import Foundation
import CoreDomain

public struct CardTransactionDTO: BaseTransactionDTO {
    public var logTag: String {
        return String(describing: type(of: self))
    }
    
    public var identifier: String?
    public var operationDate: Date?
    public var amount: AmountDTO?
    public var description: String?
    public var balanceCode: String?
    public var annotationDate: Date?
    public var transactionDay: String?
    public var originalCurrency: CurrencyDTO?
    public var state: CardTransactionStatus?
    public var postedDate: String?
    public var recipient: String?
    public var cardAccountNumber: String?
    public var operationType: String?
    public var sourceDate: String?
    public var receiptId: String?

    public init() {}
}

// MARK: - Poland
public extension CardTransactionDTO {
    enum CardTransactionStatus: String, Codable {
        case none
        case processed = "PROCESSED_MEMO_TO_BE_POSTED"
        case authorisation = "CARD_AUTHORISATION"
        case posted = "POSTED"
        case processing = "PROCESSING_TO_BE_SENT"
        case sent = "PROCESSING_SENT"
        case rejected = "REJECTED"
        
        public var hidden: Bool {
            switch self {
            case .none, .processed, .posted: return true
            default: return false
            }
        }
        
        public var title: String {
            switch self {
            case .authorisation: return "transaction_label_blockadeStatus"
            case .processing, .sent: return "transaction_label_pendingStatus"
            case .rejected: return "transaction_label_rejectedStatus"
            default: return ""
            }
        }
        
        public static func getState(_ rawValue: String?) -> CardTransactionStatus {
            guard let rawValue = rawValue else { return .none }
            return CardTransactionStatus.init(rawValue: rawValue) ?? .none
        }
    }
}

extension CardTransactionDTO: CardTransactionRepresentable {
    public var amountRepresentable: AmountRepresentable? {
        return amount
    }
    
    public var transactionDate: Date? {
        return self.operationDate
    }
    
}
