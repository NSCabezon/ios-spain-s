//
//  LoginWithPersistedUserUseCase.swift
//  Login
//
//  Created by Juan Carlos López Robles on 11/17/20.
//

import Foundation
import CoreFoundationLib
import SANLibraryV3
import ESCommons
import SANSpainLibrary
import SANServicesLibrary
import CoreDomain

public class LoginWithPersistedUserUseCase: UseCase<LoginWithPersistedUserUseCaseInput, Void, LoginUseCaseErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let trackerManager: TrackerManager
    private let pfmErrorResolver: PFMErrorResolverProtocol
    private let validator: LocalValidationProtocol
    private let bsanManagersProvider: BSANManagersProvider
    private let appRepository: AppRepositoryProtocol
    private let appConfig: AppConfigRepositoryProtocol
    private let pullOffersRepository: PullOffersRepositoryProtocol
    private let demoInterpreter: DemoInterpreterProtocol
    private let compilation: CompilationProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.trackerManager = self.dependenciesResolver.resolve(for: TrackerManager.self)
        self.pfmErrorResolver = self.dependenciesResolver.resolve(for: PFMErrorResolverProtocol.self)
        self.validator = self.dependenciesResolver.resolve(for: LocalValidationProtocol.self)
        self.bsanManagersProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        self.appConfig = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        self.pullOffersRepository = self.dependenciesResolver.resolve(for: PullOffersRepositoryProtocol.self)
        self.demoInterpreter = self.dependenciesResolver.resolve(for: DemoInterpreterProtocol.self)
        self.compilation = self.dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    public override func executeUseCase(requestValues: LoginWithPersistedUserUseCaseInput) throws -> UseCaseResponse<Void, LoginUseCaseErrorOutput> {
        let persistedUserResponse = appRepository.getPersistedUser()
        if !persistedUserResponse.isSuccess() {
            return UseCaseResponse.error(LoginUseCaseErrorOutput(loginErrorType: LoginErrorType.persistedUserFailed))
        }
        
        guard let persistedUserDTO = try persistedUserResponse.getResponseData() else {
            return UseCaseResponse.error(LoginUseCaseErrorOutput(loginErrorType: LoginErrorType.persistedUserFailed))
        }
        
        self.updateRestAndSoapClients(user: persistedUserDTO.login)
        
        let authResponse: UseCaseResponse<Void, LoginUseCaseErrorOutput>
        switch requestValues.authLogin {
        case .magic(let magic):
            authResponse = try magicLogin(persistedUserDTO: persistedUserDTO, magic: magic)
        case .biometric(let biometricToken, let footprint, let channelFrame, let isPb):
            authResponse = try biometricLogin(persistedUserDTO: persistedUserDTO, biometricToken: biometricToken, footprint: footprint, channelFrame: channelFrame, isPb: isPb)
        }
        if authResponse.isOkResult {
            self.trackerManager.trackEmma(token: LoginConstants.loginOk)
            self.pfmErrorResolver.resolve()
            self.startRepositoriesSession()
            let token = try self.bsanManagersProvider.getBsanAuthManager().getAuthCredentials().soapTokenCredential
            try self.dependenciesResolver.resolve(for: UserSessionRepository.self).saveToken(token)
        }
        
        return authResponse
    }
}

extension LoginWithPersistedUserUseCase: Cancelable {
    public func cancel() {   }
}

private extension LoginWithPersistedUserUseCase {
    func magicLogin(persistedUserDTO: PersistedUserDTO, magic: String) throws -> UseCaseResponse<Void, LoginUseCaseErrorOutput> {
        let magicTrimmed = magic.trim()
        
        // validate versionBlocked
        if let errorOutput = self.validator.validate(userLoginType: persistedUserDTO.loginType, login: persistedUserDTO.login, pass: magicTrimmed) {
            return UseCaseResponse.error(LoginUseCaseErrorOutput(loginErrorType: errorOutput))
        }
        
        let authenticateResponse = try bsanManagersProvider.getBsanAuthManager().authenticate(login: persistedUserDTO.login, magic: magicTrimmed, loginType: persistedUserDTO.loginType, isDemo: demoInterpreter.isDemoUser(userName: persistedUserDTO.login))
        if authenticateResponse.isSuccess() {
            return UseCaseResponse.ok()
        }
        let authenticateResponseErrorMessage = try authenticateResponse.getErrorMessage()
        let authenticateResponseErrorCode = try authenticateResponse.getErrorCode()
        let error = LoginServiceErrorAdapter(errorDesc: authenticateResponseErrorMessage, code: authenticateResponseErrorCode)
        return UseCaseResponse.error(error)
    }
    
    func biometricLogin(persistedUserDTO: PersistedUserDTO, biometricToken: String, footprint: String, channelFrame: String, isPb: Bool) throws -> UseCaseResponse<Void, LoginUseCaseErrorOutput> {
        
        if let appActive = self.appConfig.getBool(LoginConstants.appConfigActive), !appActive {
            let activeMessage: String? = self.appConfig.getString(LoginConstants.appConfigActiveMessage)
            let error = LoginServiceErrorAdapter(errorDesc: activeMessage, code: nil)
            return UseCaseResponse.error(error)
        }
        
        let authenticateResponse = try bsanManagersProvider.getBsanAuthManager().loginTouchId(footPrint: footprint, deviceToken: biometricToken, login: persistedUserDTO.login, channelFrame: channelFrame, userType: persistedUserDTO.loginType, isDemo: demoInterpreter.isDemoUser(userName: persistedUserDTO.login), isPb: isPb)
        
        guard authenticateResponse.isSuccess() else {
            let message = try authenticateResponse.getErrorMessage()
            let code = try authenticateResponse.getErrorCode()
            let error = LoginServiceErrorAdapter(errorDesc: message, code: code, notFoundTye: .biometric)
            return UseCaseResponse.error(error)
        }
        
        if let response = try authenticateResponse.getResponseData(), let deviceMagicPhrase = response.deviceMagicPhrase {
            let touchIdData = TouchIdData(deviceMagicPhrase: deviceMagicPhrase,
                                          touchIDLoginEnabled: true,
                                          footprint: footprint)
            try KeychainWrapper().saveTouchIdData(touchIdData, compilation: compilation)
        }
        
        return UseCaseResponse.ok()
    }
    
    func startRepositoriesSession() {
        _ = self.appRepository.startSession()
        _ = self.pullOffersRepository.setup()
    }
    
    func updateRestAndSoapClients(user: String) {
        if self.demoInterpreter.isDemoUser(userName: user) {
            self.dependenciesResolver.resolve(for: ClientsProvider.self).update(
                client: self.dependenciesResolver.resolve(for: "NetworkDemoClient")
            )
        } else {
            self.dependenciesResolver.resolve(for: ClientsProvider.self).update(
                client: self.dependenciesResolver.resolve()
            )
        }
    }
}

public struct LoginWithPersistedUserUseCaseInput {
    let authLogin: AuthLogin
    
    public init(authLogin: AuthLogin) {
        self.authLogin = authLogin
    }
}
