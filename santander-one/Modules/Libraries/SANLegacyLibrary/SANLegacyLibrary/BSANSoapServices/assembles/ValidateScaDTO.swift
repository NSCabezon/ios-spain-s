import Foundation

public enum SendViaSca: String, Codable {
    case push = "PUSH"
    case sms = "SMS"
}

public struct ValidateScaDTO: Codable  {
    public let tokenOTP: String?
    public let ticket: String?
    public let deviceTelephone: String?
    public let telephone: String?
    public let via: SendViaSca?
    public let forwardingRemaining: Int?
    
    public init(
        tokenOTP: String?,
        ticket: String?,
        deviceTelephone: String?,
        telephone: String?,
        via: SendViaSca?,
        forwardingRemaining: Int?
    ) {
        self.tokenOTP = tokenOTP
        self.ticket = ticket
        self.deviceTelephone = deviceTelephone
        self.telephone = telephone
        self.via = via
        self.forwardingRemaining = forwardingRemaining
    }
}
