import Foundation

public struct PensionDetailDTO: Codable {
    public var valueDate: Date?
    public var vestedRightsAmount: AmountDTO?
    public var pensionDesc: String?
    public var linkedAccountDesc: String?
    public var holder: String?
    public var linkedAccountContract: ContractDTO?
    public var settlementValueAmount: AmountDTO?
    public var sharesNumber: Decimal?

    public init() {}
}
