import Foundation

public final class BizumSendMoney {
    public var amount: AmountEntity
    public var totalAmount: AmountEntity
    public var concept: String // Concept is not nil is mandatory regardless the web service

    public static var makeEmpty: BizumSendMoney {
        return BizumSendMoney(amount: AmountEntity(value: 0), totalAmount: AmountEntity(value: 0), concept: "")
    }

    public init(amount: AmountEntity, totalAmount: AmountEntity, concept: String = "") {
        self.amount = amount
        self.totalAmount = totalAmount
        self.concept = concept
    }

    public func getAmount() -> Decimal? {
        return amount.value
    }
    
    public func setAmount(_ amount: Decimal) {
        self.amount = AmountEntity(value: amount)
    }

    public func getTotalAmount() -> Decimal? {
        return totalAmount.value
    }

    public func setTotalAmount(_ amount: Decimal) {
        return totalAmount =  AmountEntity(value: amount)
    }
}
