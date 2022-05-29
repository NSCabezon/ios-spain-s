import Foundation

public struct ConfirmSignatureActivationRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var languageISO: String
    public var dialectISO: String
    public var linkedCompany: String
    public var signatureDTO: SignatureDTO
    public var newSignatureCiphered: String
}
