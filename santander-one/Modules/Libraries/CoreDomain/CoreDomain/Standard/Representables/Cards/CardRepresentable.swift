public protocol CardRepresentable: GlobalPositionProductIdentifiable, UniqueIdentifiable {
    var alias: String? { get }
    var productIdentifier: String? { get }
    var isContractBlocked: Bool { get }
    var pan: String? { set get }
    var detailUI: String?  { get }
    var expirationDate: String? { get }
    var isCreditCard: Bool { get }
    var isPrepaidCard: Bool { get }
    var isDebitCard: Bool { get }
    var isVisible: Bool { get }
    var isTemporallyOff: Bool? { get set }
    var inactive: Bool? { get set }
    var trackId: String { get }
    var currencyRepresentable: CurrencyRepresentable? { get }
    var productSubtypeRepresentable: ProductSubtypeRepresentable? { get }
    var contractRepresentable: ContractRepresentable? { get }
    var isContractInactive: Bool { get }
    var isContractCancelled: Bool { get }
    var isContractHolder: Bool { get }
    var isContractActive: Bool { get }
    var isOwnerSuperSpeed: Bool { get }
    var visualCode: String? { get }
    var stampedName: String? { get }
    var description: String? { get }
    var creditLimitAmountRepresentable: AmountRepresentable? { get }
    var currentBalanceRepresentable: AmountRepresentable? { get }
    var availableAmountRepresentable: AmountRepresentable? { get }
    var dailyATMMaximumLimitAmountRepresentable: AmountRepresentable? { get }
    var dailyCurrentLimitAmountRepresentable: AmountRepresentable? { get }
    var dailyMaximumLimit: AmountRepresentable? { get }
    var atmLimitRepresentable: AmountRepresentable? { get }
    var ownershipTypeDesc: OwnershipTypeDesc? { get }
    var ownershipType: String? { get }
    var PAN: String? { get set }
    var cardTypeDescription: String? { get }
    var cardContractStatusType: CardContractStatusType? { get }
    var statusDescription: String? { get }
    var allowsDirectMoney: Bool? { get }
    var eCashInd: Bool { get }
    var contractDescription: String? { get }
    var indVisibleAlias : Bool? { get }
    var situation: CardContractStatusType? { get }
    var cardType: String? { get }
    var formattedPAN: String? { get }
    var isBeneficiary: Bool { get }
}

extension CardRepresentable {
    public var appIdentifier: String {
        return contractRepresentable?.formattedValue ?? ""
    }
    
    var boxType: UserPrefBoxType {
        return .card
    }
}

extension CardRepresentable {
    public var uniqueIdentifier: Int {
        var hasher = Hasher()
        hasher.combine(PAN)
        return hasher.finalize()
    }
}

extension CardRepresentable {
    public var trackId: String {
        switch cardType?.first?.uppercased() {
        case "C":
            return "credito"
        case "D":
            return "debito"
        case "P":
            return "prepago"
        default:
            return ""
        }
    }
}
