public protocol PensionRepresentable: GlobalPositionProductIdentifiable {
    var alias: String? { get }
    var contractRepresentable: ContractRepresentable? { get }
    var ownershipTypeDesc: OwnershipTypeDesc? { get }
    var currencyRepresentable: CurrencyRepresentable? { get }
    var valueAmountRepresentable: AmountRepresentable? { get }
    var contractStatusDesc: String? { get }
    var sharesNumber: Decimal? { get }
    var productSubtypeRepresentable: ProductSubtypeRepresentable? { get }
    var contractDescription: String? { get }
    var indVisibleAlias : Bool? { get }
    var counterValueAmountRepresentable: AmountRepresentable? { get }
}

extension PensionRepresentable {
    public var appIdentifier: String {
        return contractRepresentable?.formattedValue ?? ""
    }
    
    public var boxType: UserPrefBoxType {
        return .pension
    }
}
