public protocol FundRepresentable: GlobalPositionProductIdentifiable {
    var alias: String? { get }
    var contractRepresentable: ContractRepresentable? { get }
    var ownershipTypeDesc: OwnershipTypeDesc? { get }
    var ownershipType: String? { get }
    var currencyRepresentable: CurrencyRepresentable? { get }
    var sharesNumber: Decimal? { get }
    var valueAmountRepresentable: AmountRepresentable? { get }
    var contractStatusDesc: String? { get }
    var productSubtypeRepresentable: ProductSubtypeRepresentable? { get }
    var contractDescription: String? { get }
    var indVisibleAlias : Bool? { get }
    var countervalueAmountRepresentable: AmountRepresentable? { get }
    var profitabilityPercent: Decimal? { get }
    var profitabilityAmountRepresentable: AmountRepresentable? { get }
}

extension FundRepresentable {
    public var appIdentifier: String {
        return contractRepresentable?.formattedValue ?? ""
    }
    
    public var boxType: UserPrefBoxType {
        return .fund
    }
}
