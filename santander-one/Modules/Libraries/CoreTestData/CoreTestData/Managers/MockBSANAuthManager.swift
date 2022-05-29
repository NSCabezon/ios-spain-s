import SANLegacyLibrary

struct MockBSANAuthManager: BSANAuthManager {
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func authenticate(login: String, magic: String, loginType: UserLoginType, isDemo: Bool) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func refreshToken() throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func loginTouchId(footPrint: String, deviceToken: String, login: String, channelFrame: String, userType: UserLoginType, isDemo: Bool, isPb: Bool) throws -> BSANResponse<TouchIdLoginDTO> {
        let dto = self.mockDataInjector.mockDataProvider.authData.loginTouchId
        return BSANOkResponse(dto)
    }
    
    func tryOauthLogin(bsanEnvironmentDTO: BSANEnvironmentDTO, tokenCredential: String) -> TokenOAuthDTO? {
        let tokenOAuthDTO = self.mockDataInjector.mockDataProvider.authData.tryOauthLogin
        return tokenOAuthDTO
    }
    
    func logout() -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func initSession(login: String, userType: UserLoginType) {
        
    }
    
    func getAuthCredentials() throws -> AuthCredentials {
        let authCredentialsDTO = self.mockDataInjector.mockDataProvider.authData.getAuthCredentials
        return authCredentialsDTO!
    }
    
    func requestOAuth() throws {
        
    }
}
