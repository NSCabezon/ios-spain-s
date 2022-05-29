import CoreDomain

public struct OTPValidationDTO: Codable {
    public var magicPhrase: String?
    public var ticket: String?
    public var otpExcepted = false
    
    enum CodingKeys: String, CodingKey {
        case magicPhrase = "token"
        case ticket
        case otpExcepted
    }
    
    public init() {}
    
    public init(magicPhrase: String?, ticket: String?, otpExcepted: Bool){
        self.magicPhrase = magicPhrase
        self.ticket = ticket
        self.otpExcepted = otpExcepted
    }
}

extension OTPValidationDTO: SCARepresentable {
    public var type: SCARepresentableType {
        return .otp(self)
    }
}

extension OTPValidationDTO: OTPValidationRepresentable { }
