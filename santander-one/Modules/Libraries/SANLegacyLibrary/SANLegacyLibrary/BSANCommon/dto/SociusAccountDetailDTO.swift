public struct SociusAccountDetailDTO: Codable {
    public var sociusAccountList: [SociusAccountDTO] = []
    public var totalLiquidation: SociusLiquidationDTO?
    public var particularLiquidation: SociusLiquidationDTO?
    public var pymesLiquidation: SociusLiquidationDTO?
    public var miniLiquidation: SociusLiquidationDTO?
    public var smartLiquidation: SociusLiquidationDTO?

    public init () {}
}
