import Foundation

public struct ChangePasswordRequestParams {
    public var token: String
    public var oldPasswordCiphered: String
    public var newPasswordCiphered: String
    public var userDataDTO: UserDataDTO
    public var languageISO: String
    public var dialectISO: String
    public var linkedCompany: String
}
