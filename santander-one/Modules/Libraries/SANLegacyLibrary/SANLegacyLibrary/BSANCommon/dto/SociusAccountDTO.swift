public struct SociusAccountDTO: Codable {
    public var cardsFulfillment: SociusFulfillmentDTO?
    public var receiptsFulfillment: SociusFulfillmentDTO?
    public var accountFulfillment: SociusFulfillmentDTO?
    public var account: String?
    public var sociusAccountStateDTO: SociusAccountStateDTO?
    public var sociusLiquidation: SociusLiquidationDTO?
    public var accountType: SociusAccountType?
    public var taxationDTO: TaxationDTO?

    public init () {}
}
