public struct TransferBasicDataDTO: Codable {
    public var iban: IBANDTO?
    public var concept: String?
    public var transferAmount: AmountDTO?
    public var beneficiaryBAOName: String
    public var beneficiary: String?
    
    public init() {
        self.beneficiaryBAOName = ""
    }
}
