//
import Foundation

public struct BizumValidateMoneyTransferOTPDTO: Codable {
    public let info: BizumTransferInfoDTO
    public let ticket: String?
    public let stepToken: String
    public let ticketSN: String?
    
    public var otp: OTPValidationDTO {
        return OTPValidationDTO(magicPhrase: self.stepToken, ticket: self.ticket, otpExcepted: self.ticketSN != "S")
    }
    
    private enum CodingKeys: String, CodingKey {
        case info = "info"
        case ticket = "ticket"
        case stepToken = "tokenPasos"
        case ticketSN = "ticketSN"
    }
}
