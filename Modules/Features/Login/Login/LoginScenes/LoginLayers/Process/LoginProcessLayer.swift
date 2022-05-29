//
//  LoginProcessLayer.swift
//  Login
//
//  Created by Juan Carlos López Robles on 11/19/20.
//

import Foundation
import CoreFoundationLib

public protocol LoginProcessLayerEventDelegate: class {
    func handle(event: LoginProcessLayerEvent)
}

public protocol LoginProcessLayerProtocol: Cancelable {
    func restore()
    func doLogin(with loginType: LoginType)
    func setDelegate(_ delegate: LoginProcessLayerEventDelegate)
}

public class LoginProcessLayer: LoginProcessLayerProtocol {
    private let dependenciesResolver: DependenciesResolver
    private weak var delegate: LoginProcessLayerEventDelegate?
    private weak var cancelableUseCase: Cancelable?
    private var isCanceled: Bool = false
    
    private var loginWithPersistedUserUseCase: LoginWithPersistedUserUseCase {
        self.dependenciesResolver.resolve(for: LoginWithPersistedUserUseCase.self)
    }
    
    private var loginUseCase: LoginUseCase {
        self.dependenciesResolver.resolve(for: LoginUseCase.self)
    }
    
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    private var logTag: String {
        return String(describing: type(of: self))
    }
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func doLogin(with loginType: LoginType) {
        self.delegate?.handle(event: .willLogin)
        switch loginType {
        case .notPersisted(let identification, let magic, let type, let remember):
            self.doNonPersistedLogin(identification: identification, magic: magic, type: type, remember: remember)
        case .persisted(let authLogin):
            self.doPersistedLogin(by: authLogin)
        }
    }
    
    public func restore() {
        self.isCanceled = false
    }
    
    public func setDelegate(_ delegate: LoginProcessLayerEventDelegate) {
        self.delegate = delegate
    }
    
    public func cancel () {
        self.isCanceled = true
        self.cancelableUseCase?.cancel()
    }
}

private extension LoginProcessLayer {
    private func doNonPersistedLogin(identification: String, magic: String?, type: LoginIdentityDocumentType, remember: Bool) {
        let input = LoginUseCaseInput(username: identification, magic: magic, loginIdentityDocumentType: type, registerUser: remember)
        let useCase = self.loginUseCase.setRequestValues(requestValues: input)
        guard let loginUseCase = useCase as? LoginUseCase else { return }
        self.loginWith(useCase: loginUseCase, authLogin: .magic(magic ?? ""))
    }
    
    private func doPersistedLogin(by authLogin: AuthLogin) {
        let input = LoginWithPersistedUserUseCaseInput(authLogin: authLogin)
        let useCase = self.loginWithPersistedUserUseCase.setRequestValues(requestValues: input)
        guard let persistedUserUsecase = useCase as? LoginWithPersistedUserUseCase else { return }
        self.loginWith(useCase: persistedUserUsecase, authLogin: authLogin)
    }
    
    private func loginWith<Input, Output, Error>(useCase: UseCase<Input, Output, Error> & Cancelable, authLogin: AuthLogin)
        where Error: LoginUseCaseErrorOutput {
            self.cancelableUseCase = useCase
            
            guard !self.isCanceled else {
                delegate?.handle(event: .userCanceled)
                return
            }
            
            UseCaseWrapper(
                with: useCase,
                useCaseHandler: self.useCaseHandler,
                onSuccess: { [weak self] _ in
                    self?.loginSuccess()
                }, onError: { [weak self] error in
                    guard let self = self else { return }
                    let errorLayer = LoginProcessLayerError<Error>(
                        dependenciesResolver: self.dependenciesResolver,
                        useCaseError: error,
                        authLogin: authLogin)
                    self.delegate?.handle(event: errorLayer.failEvent())
            })
    }
    
    private func loginSuccess() {
        delegate?.handle(event: .loginSuccess)
    }
}
