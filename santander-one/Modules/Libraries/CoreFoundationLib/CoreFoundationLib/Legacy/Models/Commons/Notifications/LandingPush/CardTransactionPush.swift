import Foundation

public protocol AlertInfoType {
    var name: String { get }
    var category: String { get }
    var user: String { get }
}

public struct CardTransactionPush: Codable {
    public var cardName: String
    public var bin: String
    public var cardType: String
    public var pan: String
    public var date: String
    public var currency: String
    public var value: String
    public var commerce: String
    public let cardPlasticCode: String?
    public let productCode: String?
    public let subProductCode: String?
    
    public init(cardName: String,
                bin: String,
                cardType: String,
                pan: String,
                date: String,
                currency: String,
                value: String,
                commerce: String,
                cardPlasticCode: String?,
                productCode: String?,
                subProductCode: String?) {
        self.cardName = cardName
        self.bin = bin
        self.cardType = cardType
        self.pan = pan
        self.date = date
        self.currency = currency
        self.value = value
        self.commerce = commerce
        self.cardPlasticCode = cardPlasticCode
        self.productCode = productCode
        self.subProductCode = subProductCode
    }
    
    public func getCardType() -> CardTypePush {
        switch cardType {
        case "1":
            return .credit
        case "2":
            return .debit
        case "0":
            return .debit
        default:
            return .other
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case cardName
        case bin
        case cardType
        case pan
        case date
        case currency
        case value
        case commerce
        case cardPlasticCode = "codPlast"
        case productCode = "codProd"
        case subProductCode = "codSProd"
    }
}

public struct CardAlertPush: Codable {
    public var name: String
    public var category: String
    public var user: String
    
    public init(name: String, category: String, user: String) {
        self.name = name
        self.category = category
        self.user = user
    }
}

extension CardAlertPush: AlertInfoType {}
 
public enum CardTypePush {
    case credit
    case debit
    case other
}
