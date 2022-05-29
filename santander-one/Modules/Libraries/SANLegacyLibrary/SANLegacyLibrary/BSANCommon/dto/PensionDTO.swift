import CoreDomain

public struct PensionDTO: BaseProductDTO {
	public var alias: String?
	public var contract: ContractDTO?
	public var ownershipTypeDesc: OwnershipTypeDesc?
	public var currency: CurrencyDTO?
    public var valueAmount: AmountDTO?
    public var contractStatusDesc: String?
    public var sharesNumber: Decimal?
    public var productSubtypeDTO: ProductSubtypeDTO?
    public var contractDescription: String?
    public var indVisibleAlias : Bool?
    public var counterValueAmount: AmountDTO?

    public init() {}
}

extension PensionDTO: PensionRepresentable {
    public var contractRepresentable: ContractRepresentable? {
        return contract
    }
    public var currencyRepresentable: CurrencyRepresentable? {
        return currency
    }
    public var valueAmountRepresentable: AmountRepresentable? {
        return valueAmount
    }
    public var productSubtypeRepresentable: ProductSubtypeRepresentable? {
        return productSubtypeDTO
    }
    public var counterValueAmountRepresentable: AmountRepresentable? {
        return counterValueAmount
    }
}
