import CoreDomain

public struct PortfolioDTO: BaseProductDTO {
	public var alias: String?
	public var contract: ContractDTO?
	public var ownershipTypeDesc: OwnershipTypeDesc?
	public var currency: CurrencyDTO?
    public var accountDesc: String?
    public var holderName: String?
    public var portfolioId: String?
    public var portfolioType: String?
    public var availabilityInd: String?
    public var portfolioTypeInd: String?
    public var portfolioTypeDesc: String?
    public var consolidatedBalance: AmountDTO?
    public var stockAccountData: AccountDataDTO?

    public init() {}
}

extension PortfolioDTO: PortfolioRepresentable {
    public var contractRepresentable: ContractRepresentable? {
        return contract
    }
    public var currencyRepresentable: CurrencyRepresentable? {
        return currency
    }
    public var consolidatedBalanceRepresentable: AmountRepresentable? {
        return consolidatedBalance
    }
    public var stockAccountDataRepresentable: AccountDataRepresentable? {
        return stockAccountData
    }
}
