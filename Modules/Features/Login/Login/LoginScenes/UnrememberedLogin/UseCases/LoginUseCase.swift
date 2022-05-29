//
//  LoginUseCase.swift
//  Login
//
//  Created by Juan Carlos López Robles on 11/16/20.
//

import Foundation
import CoreFoundationLib
import SANLibraryV3
import ESCommons
import SANSpainLibrary
import SANServicesLibrary
import CoreDomain

public enum LoginStateToCancel {
    case none
    case requests
    case session
    case finish(register: Bool)
}

public final class LoginUseCase: UseCase<LoginUseCaseInput, Void, LoginUseCaseErrorOutput> {
    private let documentFormatter: DocumentFormatterProtocol
    private let dependenciesResolver: DependenciesResolver
    private let bsanManagersProvider: BSANManagersProvider
    private let appRepository: AppRepositoryProtocol
    private let pullOffersRepository: PullOffersRepositoryProtocol
    private let demoInterpreter: DemoInterpreterProtocol
    private let pfmErrorResolver: PFMErrorResolverProtocol
    private let trackerManager: TrackerManager
    private let validator: LocalValidationProtocol
    private var isCanceled = false
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.documentFormatter = self.dependenciesResolver.resolve(for: DocumentFormatterProtocol.self)
        self.bsanManagersProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        self.pullOffersRepository = self.dependenciesResolver.resolve(for: PullOffersRepositoryProtocol.self)
        self.demoInterpreter = self.dependenciesResolver.resolve(for: DemoInterpreterProtocol.self)
        self.pfmErrorResolver = self.dependenciesResolver.resolve(for: PFMErrorResolverProtocol.self)
        self.trackerManager = self.dependenciesResolver.resolve(for: TrackerManager.self)
        self.validator = self.dependenciesResolver.resolve(for: LocalValidationProtocol.self)
    }

    public override func executeUseCase(requestValues: LoginUseCaseInput) throws -> UseCaseResponse<Void, LoginUseCaseErrorOutput> {
        
        let usernameFormatted = self.formatUserName(requestValues.username, forLoginType: requestValues.loginIdentityDocumentType.dto)

        if let error = self.checkCancelLogin(state: .none) {
            return error
        }
        
        guard let magicTrimmed = requestValues.magic?.trim() else {
            let error = LoginServiceErrorAdapter(errorDesc: nil, code: nil)
            return UseCaseResponse.error(error)
        }
        
        if let errorOutput = self.validator.validate(userLoginType: requestValues.loginIdentityDocumentType.dto, login: usernameFormatted, pass: magicTrimmed) {
            return UseCaseResponse.error(LoginUseCaseErrorOutput(loginErrorType: errorOutput))
        }
        
        if let error = self.checkCancelLogin(state: .none) {
            return error
        }
        
        self.updateRestAndSoapClients(user: requestValues.username)
        
        let authenticateResponse = try self.bsanManagersProvider.getBsanAuthManager().authenticate(login: usernameFormatted, magic: magicTrimmed, loginType: requestValues.loginIdentityDocumentType.dto, isDemo: self.demoInterpreter.isDemoUser(userName: usernameFormatted))
        
        guard authenticateResponse.isSuccess() else {
            let error = LoginServiceErrorAdapter(errorDesc: try authenticateResponse.getErrorMessage(), code: try authenticateResponse.getErrorCode())
            return UseCaseResponse.error(error)
        }
        
        if let error = self.checkCancelLogin(state: .requests) {
            return error
        }
        
        self.startRepositoriesSession()
        
        if let error = self.checkCancelLogin(state: .session) {
            return error
        }
        
        if requestValues.registerUser {
            guard let bsanEnvironment: BSANEnvironmentDTO = try self.bsanManagersProvider.getBsanEnvironmentsManager().getCurrentEnvironment().getResponseData() else {
                return UseCaseResponse.error(LoginUseCaseErrorOutput(loginErrorType: LoginErrorType.persistedUserFailed))
            }
            self.storePersistedUser(requestValues.loginIdentityDocumentType.dto, usernameFormatted, bsanEnvironment.name)
        } else {
            self.removePersistedUser()
        }
        
        if let error = self.checkCancelLogin(state: .finish(register: requestValues.registerUser)) {
            return error
        }
        // SI NO HAY USUARIO RECORDADO, ALMACENO login Y tipoLogin PARA TENERLO EN CASO DE QUE EL USUARIO MARQUE LOGIN CON TOUCHID
        if try self.appRepository.getPersistedUser().getResponseData() == nil, let environmentName = try self.bsanManagersProvider.getBsanEnvironmentsManager().getCurrentEnvironment().getResponseData() {
            _ = self.appRepository.setTempLogin(tempLogin: usernameFormatted)
            _ = self.appRepository.setTempUserType(userType: requestValues.loginIdentityDocumentType.dto)
            _ = self.appRepository.setTempEnvironmentName(tempEnvironmentName: environmentName.name)
        }
        
        self.pfmErrorResolver.resolve()
        let trackerManager = self.dependenciesResolver.resolve(for: TrackerManager.self)
        self.trackerManager.trackEmma(token: LoginConstants.loginOk)
        
        let token = try self.bsanManagersProvider.getBsanAuthManager().getAuthCredentials().soapTokenCredential
        try self.dependenciesResolver.resolve(for: UserSessionRepository.self).saveToken(token)
        return UseCaseResponse.ok()
    }
}

private extension LoginUseCase {
    func formatUserName(_ userName: String, forLoginType loginType: UserLoginType) -> String {
        var usernameFormatted: String = ""

        switch loginType {
        case .N:
            usernameFormatted = self.documentFormatter.format(document: userName)
        case .I:
            usernameFormatted = self.documentFormatter.format(passport: userName)
        default:
            usernameFormatted = userName
        }

        return usernameFormatted.trim()
    }
    
    func checkCancelLogin (state: LoginStateToCancel) -> UseCaseResponse<Void, LoginUseCaseErrorOutput>? {
        if isCanceled {
            switch state {
            case .none:
                break
            case .requests:
                _ = self.bsanManagersProvider.getBsanSessionManager().logout()
            case .session:
                _ = self.appRepository.closeSession()
                _ = self.pullOffersRepository.reset()
                _ = self.bsanManagersProvider.getBsanSessionManager().logout()
            case .finish(let register):
                _ = self.appRepository.closeSession()
                _ = self.pullOffersRepository.reset()
                _ = self.bsanManagersProvider.getBsanSessionManager().logout()
                if register {
                    self.removePersistedUser()
                }
            }
            return UseCaseResponse.error(LoginUseCaseErrorOutput(loginErrorType: LoginErrorType.userCanceled))
        } else {
            return nil
        }
    }
    
    func startRepositoriesSession() {
        _ = self.appRepository.startSession()
        _ = self.pullOffersRepository.setup()
    }

    func removePersistedUser() {
        _ = self.appRepository.removePersistedUser()
    }
    
    func storePersistedUser(_ userLoginType: UserLoginType, _  login: String, _ environmentName: String) {
        _ = self.appRepository.setPersistedUserDTO(persistedUserDTO: PersistedUserDTO.createPersistedUser(loginType: userLoginType, login: login, environmentName: environmentName))
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

extension LoginUseCase: Cancelable {
    public func cancel() {
        self.isCanceled = true
    }
}

public struct LoginUseCaseInput {
    public let username: String
    public let magic: String?
    public let loginIdentityDocumentType: LoginIdentityDocumentType
    public let registerUser: Bool
    
    public init(username: String, magic: String?,
                loginIdentityDocumentType: LoginIdentityDocumentType, registerUser: Bool) {
        self.username = username
        self.magic = magic
        self.loginIdentityDocumentType = loginIdentityDocumentType
        self.registerUser = registerUser
    }
}
