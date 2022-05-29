public struct FundMifidClauseDTO: Codable {
    public var fileTypeDTO: FileTypeDTO?
    public var clauseType: InstructionStatusDTO?
    public var prodClause: InstructionStatusDTO?
    public var lineCount: Int?
    public var clauseDesc: String?

    public init() {}
}
