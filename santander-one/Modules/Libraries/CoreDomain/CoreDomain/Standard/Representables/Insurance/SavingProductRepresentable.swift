public protocol SavingProductRepresentable: GlobalPositionProductIdentifiable {
    var accountId: String? { get }
    var alias: String? { get }
    var identification: String? { get }
    var accountSubType: String? { get }
    var interestRate: String? { get }
    var interestRateLinkRepresentable: InterestRateLinkRepresentable? { get }
    var currentBalanceRepresentable: AmountRepresentable? { get }
    var balanceIncludedPendingRepresentable: AmountRepresentable? { get }
    var contractRepresentable: ContractRepresentable? { get }
    var currencyRepresentable: CurrencyRepresentable? { get }
    var ownershipTypeDesc: OwnershipTypeDesc? { get }
    var counterValueAmountRepresentable: AmountRepresentable? { get }
}

public protocol InterestRateLinkRepresentable {
    var title: String { get }
    var url: String { get }
}

extension SavingProductRepresentable {
    public var appIdentifier: String {
        return contractRepresentable?.formattedValue ?? ""
    }
    
    public var boxType: UserPrefBoxType {
        return .savingProduct
    }
}
