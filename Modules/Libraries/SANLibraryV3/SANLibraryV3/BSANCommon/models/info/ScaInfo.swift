public struct ScaInfo: Codable {
    public var sca: CheckScaDTO?
    public var scaCheckFail: Bool = false
    public var scaAccountsOtpOk: Bool = false
    public var scaLoginOtpOk: Bool = false
}
