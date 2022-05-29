public protocol PortfolioRepresentable: GlobalPositionProductIdentifiable {
    var alias: String? { get }
    var contractRepresentable: ContractRepresentable? { get }
    var ownershipTypeDesc: OwnershipTypeDesc? { get }
    var currencyRepresentable: CurrencyRepresentable? { get }
    var accountDesc: String? { get }
    var holderName: String? { get }
    var portfolioId: String? { get }
    var portfolioType: String? { get }
    var availabilityInd: String? { get }
    var portfolioTypeInd: String? { get }
    var portfolioTypeDesc: String? { get }
    var consolidatedBalanceRepresentable: AmountRepresentable? { get }
    var stockAccountDataRepresentable: AccountDataRepresentable? { get }
}

extension PortfolioRepresentable {
    public var appIdentifier: String {
        return contractRepresentable?.formattedValue ?? ""
    }
    
    public var boxType: UserPrefBoxType {
        if portfolioTypeInd == "A" {
            return .managedPortfolio
        } else {
            return.notManagedPortfolio
        }
    }
}
