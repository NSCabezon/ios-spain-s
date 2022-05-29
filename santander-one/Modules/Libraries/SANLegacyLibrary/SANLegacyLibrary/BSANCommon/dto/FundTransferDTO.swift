public struct FundTransferDTO: Codable {
    public var tokenPasos: String?
    public var holderName: String?
    public var linkedAccount: IBANDTO?
    public var mifidAction: InstructionStatusDTO?
    public var fundDescription: String?
    public var fundMifidClauseDataList: [FundMifidClauseDTO]?
    public var fundTransferResponseData: FundTransferResponseDataDTO?
    public var varClauseDesc: String?
    public var OblClauseDesc: String?
    public var signature: SignatureDTO?
    // Mifid V3
    public var mifidAdviceModel: MifidAdviceDTO?

    public init() {}
}
