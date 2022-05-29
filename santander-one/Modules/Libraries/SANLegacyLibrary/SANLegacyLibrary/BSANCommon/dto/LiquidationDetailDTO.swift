public struct LiquidationDetailDTO: Codable {
    public var liquidationItemDetailDTOList: [LiquidationItemDetailDTO]?
    public var totalCredit: AmountDTO?
    public var totalDebit: AmountDTO?
    
    public init() {}
}
