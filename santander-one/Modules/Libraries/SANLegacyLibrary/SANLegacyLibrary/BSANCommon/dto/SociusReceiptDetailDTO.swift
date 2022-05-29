public struct SociusReceiptDetailDTO: Codable {
    public var cif: String?
    public var cifDesc: String?
    public var lastLiquidationReceiptsCount: Int?
    public var lastLiquidationAmount: AmountDTO?
    public var totalLiquidationReceiptsCount: Int?
    public var totalLiquidationAmount: AmountDTO?

    public init () {}
}
