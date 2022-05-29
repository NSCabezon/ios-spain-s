import Foundation

public struct FundTransferResponseDataDTO: Codable {
    public var accessPersonNumber: ClientDTO?
    public var destinationFundCode: String?
    public var destinationFundName: String?
    public var valueDate: Date?
    public var transferTypeByManagingCompany: String?
    public var quantityToSplit: String?
    public var partialTransferQuantity: String?
    public var originIsinCode: String?
    public var originManagingCompanyCIF: String?
    public var counter: String?
    public var fundCurrencyAvailableAmount: AmountDTO?
    public var fundShares: String?
    public var transferShares: String?
    public var debitSharesBalance: String?

    public init() {}
}
