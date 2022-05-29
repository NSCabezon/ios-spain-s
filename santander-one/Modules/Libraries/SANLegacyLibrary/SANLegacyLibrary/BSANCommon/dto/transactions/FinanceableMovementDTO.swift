import SwiftyJSON
import CoreDomain

public struct FinanceableMovementDTO: Codable {
    public let movementId: String?
    public let amount: AmountDTO?
    public let normalIndicator: Int?
    public let liquidationDate: String?
    public let operationDate: String?
    public let accountingDate: String?
    public let elegibleFinance: String?
    public let description: String?
    public let clearedIndicator: ClearedIndicator?
    public let movementType: FinanceableMovementType?
    public let status: EasyPayStatus?
    public let originalCurrency: CurrencyDTO?
    public let balanceCode: String?
    public let transactionDay: String?

    public init(json: JSON) {
        self.amount = AmountDTO(json: json)
        self.movementId = json["movementId"].string
        self.normalIndicator = json["normalIndicator"].int
        self.liquidationDate = json["liquidationDate"].string
        self.operationDate = json["operationDate"].string
        self.accountingDate = json["accountingDate"].string
        self.elegibleFinance = json["elegibleFinance"].string
        self.description = json["description"].string
        self.clearedIndicator = ClearedIndicator(rawValue: json["clearedIndicator"].int ?? -1)
        self.movementType = FinanceableMovementType(rawValue: json["easyPay"].int ?? -1)
        self.status = EasyPayStatus(json: json["easyPayStatus"])
        self.originalCurrency = CurrencyDTO(currencyName: json["originalCurrency"].string ?? "EUR", currencyType: CurrencyType.parse(json["originalCurrency"].string ?? "EUR"))
        let codeInt = Int(json["statementNumber"].string ?? "0") ?? 0
        self.balanceCode = String(format: "%03d", codeInt)
        self.transactionDay = String(json["movementNumber"].int ?? -1)
    }
    
    public init(movementId: String?,
                amount: AmountDTO?,
                normalIndicator: Int?,
                liquidationDate: String?,
                operationDate: String?,
                accountingDate: String?,
                elegibleFinance: String?,
                description: String?,
                clearedIndicator: ClearedIndicator?,
                movementType: FinanceableMovementType?,
                status: EasyPayStatus?,
                originalCurrency: CurrencyDTO?,
                balanceCode: String?,
                transactionDay: String?) {
        self.amount = amount
        self.movementId = movementId
        self.normalIndicator = normalIndicator
        self.liquidationDate = liquidationDate
        self.operationDate = operationDate
        self.accountingDate = accountingDate
        self.elegibleFinance = elegibleFinance
        self.description = description
        self.clearedIndicator = clearedIndicator
        self.movementType = movementType
        self.status = status
        self.originalCurrency = originalCurrency
        self.balanceCode = balanceCode
        self.transactionDay = transactionDay
    }
}

public enum ClearedIndicator: Int, Codable {
    case pending = 0
    case cleared
}

public enum FinanceableMovementType: Int, Codable {
    case normal = 0
    case canceled
    case easyPay
}

public struct EasyPayStatus: Codable {
    public let statusCode: EasyPayStatusCode?
    public let paidQuotas: Int?
    public let pendingQuotas: Int?
    public let cancelledQuotas: Int?
    
    public init?(json: JSON) {
        guard let statusCode = EasyPayStatusCode(rawValue: (json["statusCode"].string?.lowercased() ?? "")),
              let paidQuotas = json["paidQuotas"].int,
              let pendingQuotas = json["pendingQuotas"].int,
              let cancelledQuotas = json["cancelledQuotas"].int
        else { return nil }
        self.statusCode = statusCode
        self.paidQuotas = paidQuotas
        self.pendingQuotas = pendingQuotas
        self.cancelledQuotas = cancelledQuotas
    }
}

public enum EasyPayStatusCode: String, Codable {
    case pending
    case settled
    case cancelled
}
