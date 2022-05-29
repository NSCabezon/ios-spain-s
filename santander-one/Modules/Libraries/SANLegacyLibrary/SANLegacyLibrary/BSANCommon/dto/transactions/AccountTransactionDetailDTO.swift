public struct AccountTransactionDetailDTO: Codable {
    public var title: String?
    public var detailLoaded = false
    public var literalDTOs: [LiteralDTO]?
    
    public init() {}
}
