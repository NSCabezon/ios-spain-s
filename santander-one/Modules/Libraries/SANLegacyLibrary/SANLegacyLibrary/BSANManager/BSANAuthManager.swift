public protocol BSANAuthManager {
    func authenticate(login: String, magic: String, loginType: UserLoginType, isDemo: Bool) throws -> BSANResponse<Void>
    func refreshToken() throws -> BSANResponse<Void>
    func loginTouchId(footPrint: String, deviceToken: String, login: String, channelFrame: String, userType: UserLoginType, isDemo: Bool, isPb: Bool) throws -> BSANResponse<TouchIdLoginDTO>
    func tryOauthLogin(bsanEnvironmentDTO: BSANEnvironmentDTO, tokenCredential: String) -> TokenOAuthDTO?
    func logout() -> BSANResponse<Void>
    func initSession(login: String, userType: UserLoginType)
    func getAuthCredentials() throws -> AuthCredentials
    func requestOAuth() throws
}
