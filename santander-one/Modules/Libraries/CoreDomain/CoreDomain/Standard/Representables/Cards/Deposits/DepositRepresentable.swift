public protocol DepositRepresentable: GlobalPositionProductIdentifiable {
    var alias: String? { get }
    var contractRepresentable: ContractRepresentable? { get }
    var ownershipTypeDesc: OwnershipTypeDesc? { get }
    var currencyRepresentable: CurrencyRepresentable? { get }
    var balanceRepresentable: AmountRepresentable? { get }
    var clientRepresentable: ClientRepresentable? { get }
    var contractSituationDesc: String? { get }
    var contractDescription: String? { get }
    var indVisibleAlias : Bool? { get }
    var countervalueCurrentBalanceRepresentable: AmountRepresentable? { get }
}

extension DepositRepresentable {
    public var appIdentifier: String {
        return contractRepresentable?.formattedValue ?? ""
    }
    
    public var boxType: UserPrefBoxType {
        return .deposit
    }
}
