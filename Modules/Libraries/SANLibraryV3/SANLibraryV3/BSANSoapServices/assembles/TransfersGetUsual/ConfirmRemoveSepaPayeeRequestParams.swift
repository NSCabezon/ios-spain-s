import Foundation

public struct ConfirmRemoveSepaPayeeRequestParams {
    public let token: String
    public let languageISO: String
    public let dialectISO: String
    public let userDataDTO: UserDataDTO
    let signatureWithTokenDTO: SignatureWithTokenDTO
}
