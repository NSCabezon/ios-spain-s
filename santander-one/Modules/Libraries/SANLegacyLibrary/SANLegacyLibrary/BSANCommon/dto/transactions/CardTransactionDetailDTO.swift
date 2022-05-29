import Foundation
import CoreDomain

public struct CardTransactionDetailDTO: Codable {
    public var transactionTime: String?
    public var detailAmount: AmountDTO?
    public var eurAmount: AmountDTO?
    public var bankCharge: AmountDTO?
    public var liquidationDate: Date?
    public var liquidated: Bool?
    public var description: String?
    public var numTarjeta: String?
    public var bankOperation: BankOperationDTO?
    
    public init() {}
}

extension CardTransactionDetailDTO: CardTransactionDetailRepresentable {
    public var isSoldOut: Bool {
        return liquidated ?? false
    }
    
    public var soldOutDate: Date? {
        return liquidationDate
    }
    
    public var bankChargeRepresentable: AmountRepresentable? {
        return bankCharge
    }
    
    public var transactionDate: String? {
        return transactionTime
    }
}
