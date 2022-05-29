public struct MobileOperatorDTO: Codable {
    public var name: String?
    public var code: String?
    public var maxAmount: AmountDTO?
    public var minAmount: AmountDTO?
    public var sectionAmount: AmountDTO?

    public init() {}
}
