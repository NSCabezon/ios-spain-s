public struct PensionMifidClauseDTO: Codable {
    public var fileTypeDTO: FileTypeDTO?
    public var clauseType: InstructionStatusDTO?
    public var prodClause: InstructionStatusDTO?
    public var clauseDesc: String?

    public init() {}
}
