public struct MifidDTO: Codable {
    public var clauseModelList: [MifidClauseDTO]?
    public var mifidAdviceDTO: MifidAdviceDTO?

    public init() {}
}
