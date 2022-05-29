public struct FundSubscriptionDTO: Codable {
    public var tokenPasos: String?
    public var holderName: String?
    public var directDebtAccount: IBANDTO?
    public var mifidAction: InstructionStatusDTO?
    public var fundDescription: String?
    public var signature: SignatureDTO?
    public var fundSubscriptionResponseData: FundSubscriptionResponseDataDTO?
    public var varClauseDesc: String?
    public var OblClauseDesc: String?
    public var fundMifidClauseDataList: [FundMifidClauseDTO]?
    // Mifid V3
    public var mifidAdviceDTO: MifidAdviceDTO?
    
    public init() {}
}
