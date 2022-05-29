public struct MifidAdviceDTO: Codable {
    public var adviceResultCode: String?
    public var mifidEvaluationResultCode: String?
    public var adviceTitle: String?
    public var adviceMessage: String?
    
    public init() {}
}
