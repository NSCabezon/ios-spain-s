import CoreDomain

public struct DepositDTO: BaseProductDTO {
	public var alias: String?
	public var contract: ContractDTO?
	public var ownershipTypeDesc: OwnershipTypeDesc?
	public var currency: CurrencyDTO?
    public var balance: AmountDTO?
    public var client: ClientDTO?
    public var contractSituationDesc: String?
    public var contractDescription: String?
    public var indVisibleAlias : Bool?
    public var accountId: ProductID?
    public var productId: ProductID?
    public var countervalueCurrentBalance: AmountDTO?

    public init() {}
}

extension DepositDTO: DepositRepresentable {
    public var contractRepresentable: ContractRepresentable? {
        return contract
    }
    public var currencyRepresentable: CurrencyRepresentable? {
        return currency
    }
    public var balanceRepresentable: AmountRepresentable? {
        return balance
    }
    public var clientRepresentable: ClientRepresentable? {
        return client
    }
    public var countervalueCurrentBalanceRepresentable: AmountRepresentable? {
        return countervalueCurrentBalance
    }
}

extension DepositDTO {
    public struct ProductID: Codable, Hashable {
        public var id: String?
        public var systemId: Int?

        public init(id: String?, systemId: Int?) {
            self.id = id
            self.systemId = systemId
        }
    }
}
