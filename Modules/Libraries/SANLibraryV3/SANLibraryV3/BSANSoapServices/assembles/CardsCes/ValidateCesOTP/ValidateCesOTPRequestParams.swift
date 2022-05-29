import Foundation

public struct ValidateCesOTPRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var languageISO: String
    public var dialectISO: String
    public var linkedCompany: String
    public var PAN: String
    public var phone: String
    public var cardSignature: SignatureDTO?
    public var contractDTO: ContractDTO?
}
