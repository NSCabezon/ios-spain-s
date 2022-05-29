import CoreDomain

public struct StockAccountDTO: BaseProductDTO {
	public var alias: String?
	public var contract: ContractDTO?
	public var ownershipTypeDesc: OwnershipTypeDesc?
	public var currency: CurrencyDTO?
	
    public var contractDescription: String?
    public var referenceCode: String?
    public var valueAmount: AmountDTO?
    public var counterValueAmount: AmountDTO?
    public var indVisibleAlias : Bool?
    
    // Contravalores
    public var countervalueAmount: AmountDTO?
    public var stockAccountType: StockAccountType = .CCV
    
    public init() {
    }
}

extension StockAccountDTO: StockAccountRepresentable {
    public var contractRepresentable: ContractRepresentable? {
        return contract
    }
    public var currencyRepresentable: CurrencyRepresentable? {
        return currency
    }
    public var valueAmountRepresentable: AmountRepresentable? {
        return valueAmount
    }
    public var counterValueAmountRepresentable: AmountRepresentable? {
        return counterValueAmount
    }
    public var countervalueAmountRepresentable: AmountRepresentable? {
        return countervalueAmount
    }
}
