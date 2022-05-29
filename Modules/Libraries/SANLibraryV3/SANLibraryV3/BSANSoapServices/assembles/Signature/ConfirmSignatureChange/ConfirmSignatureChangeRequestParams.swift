import Foundation

public struct ConfirmSignatureChangeRequestParams {
    public var token: String
    public var signatureDTO: SignatureDTO
    public var newSignatureCiphered: String
    public var userDataDTO: UserDataDTO
    public var languageISO: String
    public var dialectISO: String
    public var linkedCompany: String
}
