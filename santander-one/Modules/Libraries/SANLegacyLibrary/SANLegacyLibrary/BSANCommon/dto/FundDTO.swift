import CoreDomain

public struct FundDTO: BaseProductDTO {
	public var alias: String?
	public var contract: ContractDTO?
	public var ownershipTypeDesc: OwnershipTypeDesc?
    public var ownershipType: String?
	public var currency: CurrencyDTO?
    public var sharesNumber: Decimal?
    public var valueAmount: AmountDTO?
    public var contractStatusDesc: String?
    public var productSubtypeDTO: ProductSubtypeDTO?
    public var contractDescription: String?
    public var indVisibleAlias : Bool?
    public var accountId: ProductId?
    public var productId: ProductId?
    public var countervalueAmount: AmountDTO?
    public var profitabilityPercent: Decimal?
    public var profitabilityAmount: AmountDTO?

    public init() {}
}

extension FundDTO: FundRepresentable {
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
    public var countervalueAmountRepresentable: AmountRepresentable? {
        return countervalueAmount
    }
    public var profitabilityAmountRepresentable: AmountRepresentable? {
        return profitabilityAmount
    }
}

extension FundDTO {
    public struct ProductId: Codable {
        public var id: String?
        public var systemId: Int?

        public init(id: String?, systemId: Int?) {
            self.id = id
            self.systemId = systemId
        }
    }
}
