public struct PensionMifidDTO: Codable {
    public var pensionMifidClauseDTOS: [PensionMifidClauseDTO]?
    public var adviceResultCode: String?
    public var mifidEvaluationResultCode: String?
    public var adviceTitle: String?
    public var adviceMessage: String?
    public var varClauseDesc: String?
    public var OblClauseDesc: String?
    public var actionDescription: String?
    public var mifidAction: InstructionStatusDTO?

    public init() {}
}
