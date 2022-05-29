public protocol StockAccountRepresentable: GlobalPositionProductIdentifiable {
    var alias: String? { get }
    var contractRepresentable: ContractRepresentable? { get }
    var ownershipTypeDesc: OwnershipTypeDesc? { get }
    var currencyRepresentable: CurrencyRepresentable? { get }
    var contractDescription: String? { get }
    var referenceCode: String? { get }
    var valueAmountRepresentable: AmountRepresentable? { get }
    var counterValueAmountRepresentable: AmountRepresentable? { get }
    var indVisibleAlias : Bool? { get }
    var countervalueAmountRepresentable: AmountRepresentable? { get }
    var stockAccountType: StockAccountType { get }
}

public extension StockAccountRepresentable {
    var appIdentifier: String {
        return contractRepresentable?.formattedValue ?? ""
    }
    
    var boxType: UserPrefBoxType {
        return .stock
    }
}

public enum StockAccountType: String, Codable {
    case RVManaged
    case RVNotManaged
    case CCV
}
