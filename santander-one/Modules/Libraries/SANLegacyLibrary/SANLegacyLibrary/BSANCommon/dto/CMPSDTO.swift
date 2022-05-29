public struct CMPSDTO: Codable {
    public var nameCMPS: String?
    public var clientCMPS: ClientDTO?
    public var originAccountContract: ContractDTO?
    public var ibanCMPS: IBANDTO?
    public var registeredClientInd: Bool?
    public var otpPhone: String?
    public var otpPhoneDecrypted: String?    
    public var otpExceptedInd: Bool?
    public var blackListInd: Bool?
    public var otpRegisteredInd: Bool?
    public var benefBlackListInd: Bool?
    
    public init() {}
}
