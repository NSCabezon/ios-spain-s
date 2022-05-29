import Foundation
import SANLegacyLibrary

public class BSANAuthManagerImplementation: BSANBaseManager, BSANAuthManager {
    
    private var authDataSource: AuthDataSource
    private var webServicesUrlProvider: WebServicesUrlProvider
    
    var sanSoapServices: SanSoapServices
    var sanRestServices: SanRestServices
    
    public init(sanSoapServices: SanSoapServices, sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider, authDataSource: AuthDataSource, webServicesUrlProvider: WebServicesUrlProvider) {
        self.authDataSource = authDataSource
        self.webServicesUrlProvider = webServicesUrlProvider
        self.sanSoapServices = sanSoapServices
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func authenticate(login: String, magic: String, loginType: UserLoginType, isDemo: Bool) throws -> BSANResponse<Void> {
        let bsanAssemble: BSANAssemble = BSANConfiguration.preferredAuthenticateVersion == 1 ? BSANAssembleProvider.getAuthenticateAssembleV1()
            : BSANAssembleProvider.getAuthenticateAssembleV2()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let request = AuthenticateCredentialRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            AuthenticateCredentialRequestParams.createParams()
                .setLogin(login)
                .setMagic(magic)
                .setUserType(loginType))
        
        setDemoMode(isDemo, login)
        let response: AuthenticateCredentialResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        guard meta.isOK(), let tokenCredential = response.tokenCredential else {
            return BSANErrorResponse(meta)
        }
        storeCredentials(tokenCredential: tokenCredential, tokenOAuthResponse: nil)
        initSession(login: login, userType: loginType)
        return BSANOkResponse(meta)
    }
    
    public func refreshToken() throws -> BSANResponse<Void> {
        let bsanAssemble = BSANAssembleProvider.getTokenAssemble()
        let bsanEnvironmentDTO: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let reqParams = RefreshTokenRequestParams(token: authCredentials.soapTokenCredential)
        let request = RefreshTokenRequest(
            bsanAssemble,
            bsanEnvironmentDTO.urlBase,
            reqParams
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        guard meta.isOK(), let token = response.tokenCredential else {
            return BSANErrorResponse(meta)
        }
        try updateCredentials(tokenCredential: token)
        return BSANOkResponse(meta)
    }
    
    func updateCredentials(tokenCredential: String) throws {
        bsanDataProvider.updateSoapCredentials(token: tokenCredential)
    }
    
    public func loginTouchId(footPrint: String, deviceToken: String, login: String, channelFrame: String, userType: UserLoginType, isDemo: Bool, isPb: Bool) throws -> BSANResponse<TouchIdLoginDTO>{
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getTouchIdLoginAssemble()
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData(isPb)
        let request = TouchIdLoginRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            TouchIdLoginRequestParams(
                deviceToken: deviceToken,
                footPrint: footPrint,
                userLoginType: userType.name,
                userLogin: login,
                channel: channelFrame,
                languageISO: bsanHeaderData.languageISO,
                dialectISO: bsanHeaderData.dialectISO,
                linkedCompany: bsanHeaderData.linkedCompany
            )
        )
        setDemoMode(isDemo, login)
        let response: TouchIdLoginResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        guard
            meta.isOK(),
            let tokenCredential = (response.touchIdLoginDTO.credentialsDTO?.tokenCredential)
            else { return BSANErrorResponse(meta) }
        BSANLogger.i(logTag, "Meta OK")
        storeCredentials(tokenCredential: tokenCredential, tokenOAuthResponse: nil)
        initSession(login: login, userType: userType)
        return BSANOkResponse(meta, response.touchIdLoginDTO)
    }
    
    public func tryOauthLogin(bsanEnvironmentDTO: BSANEnvironmentDTO, tokenCredential: String) -> TokenOAuthDTO? {
        guard let clientId = try? webServicesUrlProvider.getClientId(),
            let clientSecret = try? webServicesUrlProvider.getClientSecret()
            else { return nil }
        return try? authDataSource.getApiTokenCredential(
            absoluteUrl: webServicesUrlProvider.getLoginUrl(),
            clientId: clientId,
            clientSecret: clientSecret,
            scope: Constants.SCOPE,
            grantType: Constants.GRANT_TYPE,
            token: tokenCredential
        )
    }
    
    /**
     Activates demo mode.
     */
    private func setDemoMode(_ isDemo: Bool, _ demoUser: String) {
        bsanDataProvider.setDemoMode(isDemo, demoUser)
    }
    
    public func logout() -> BSANResponse<Void> {
        closeSession()
        return BSANOkEmptyResponse()
    }
    
    private func closeSession() {
        bsanDataProvider.remove(DemoMode.self)
        bsanDataProvider.remove(AuthCredentials.self)
        bsanDataProvider.remove(SessionData.self)
        bsanDataProvider.remove(GlobalSessionData.self)
    }
    
    public func initSession(login: String, userType: UserLoginType) {
        let userDTO = UserDTO(loginType: userType, login: login)
        bsanDataProvider.createSessionData(userDTO)
        bsanDataProvider.createGlobalSessionData()
    }
    
    private func storeCredentials(tokenCredential: String, tokenOAuthResponse: TokenOAuthDTO?) {
        if let tokenOAuthResponse = tokenOAuthResponse {
            bsanDataProvider.storeAuthCredentials(AuthCredentials(soapTokenCredential: tokenCredential, apiTokenCredential: tokenOAuthResponse.accessToken, apiTokenType: tokenOAuthResponse.tokenType))
        } else {
            bsanDataProvider.storeAuthCredentials(AuthCredentials(soapTokenCredential: tokenCredential))
        }
    }
    
    public func getAuthCredentials() throws -> AuthCredentials {
        return try bsanDataProvider.getAuthCredentials()
    }
    
    public func requestOAuth() throws {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let currentTokenCredentials = try bsanDataProvider.getAuthCredentials().soapTokenCredential
        let tokenOAuthResponse = tryOauthLogin(bsanEnvironmentDTO: bsanEnvironment, tokenCredential: currentTokenCredentials)
        storeCredentials(tokenCredential: currentTokenCredentials, tokenOAuthResponse: tokenOAuthResponse)
    }
}
