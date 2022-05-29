import Foundation

public struct FundSubscriptionResponseDataDTO: Codable {
    public var settlementValueDate: Date?
    public var directDebtAccountContract: ContractDTO?
    public var languageCode: String?
    public var accountCurrencyCode: String?
    public var settlementValueAmount: AmountDTO?

    public init() {}
}
