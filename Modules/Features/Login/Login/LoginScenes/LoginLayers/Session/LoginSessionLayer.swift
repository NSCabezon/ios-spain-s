//
//  LoginSessionLayer.swift
//  Login
//
//  Created by Juan Carlos López Robles on 11/19/20.
//

import Foundation
import CoreFoundationLib

protocol LoginSessionLayerEventDelegate: class, LoginSessionStateprotocol {
    func handle(event: SessionManagerProcessEvent)
    func willOpenSession(completion: @escaping () -> Void)
}

protocol LoginSessionStateprotocol: AnyObject {
    func onSuccess()
    func onBloqued()
    func onOtp(firsTime: Bool, userName: String?)
}

final class LoginSessionLayer {
    private var loginState: LoginState = .none
    private var globalPositionName: String?
    private var lastPasswordLenght: Int?
    private var isBiometricLogin = false
    private let dependenciesResolver: DependenciesResolver
    private weak var delegate: LoginSessionLayerEventDelegate?
    
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    private var sessionManager: CoreSessionManager {
        return self.dependenciesResolver.resolve(for: CoreSessionManager.self)
    }
    
    private lazy var sessionDataManager: SessionDataManager = {
        let manager = self.dependenciesResolver.resolve(for: SessionDataManager.self)
        manager.setDataManagerDelegate(self)
        manager.setDataManagerProcessDelegate(self)
        return manager
    }()
    
    private var setNeedUpdatePasswordUseCase: SetNeedUpdatePasswordUseCase {
        return self.dependenciesResolver.resolve(for: SetNeedUpdatePasswordUseCase.self)
    }
    
    private var setLastLoginDateUseCase: SetLastLoginDateUseCase {
        return self.dependenciesResolver.resolve(for: SetLastLoginDateUseCase.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.dependenciesResolver.resolve(for: LoginSessionStateHelper.self).setDelegate(self)
    }
    
    func setDelegate(_ delegate: LoginSessionLayerEventDelegate) {
        self.delegate = delegate
    }
    
    func getCloseReason() -> SessionFinishedReason? {
        self.sessionManager.lastFinishedSessionReason
    }
    
    func isSessionExpired() -> Bool {
        self.sessionManager.lastFinishedSessionReason == .timeoutInactivity
    }
    
    func setLoginState(_ loginState: LoginState) {
        self.loginState = loginState
    }
    
    func getLoginState() -> LoginState {
        return self.loginState
    }
    
    func setLastPasswordLenght(_ lenght: Int) {
        self.lastPasswordLenght = lenght
    }
    
    func setIsBiometricLogin(_ isBiometric: Bool) {
        self.isBiometricLogin = isBiometric
    }
    
    func cancel() {
        self.sessionDataManager.cancel()
    }
    
    func changeCloseReason(_ closeReason: SessionFinishedReason) {
        self.sessionManager.setLastFinishedSessionReason(closeReason)
    }
    
    func handle(event: LoginProcessLayerEvent) {
           switch event {
           case .loginSuccess:
               self.loginState = .globalPosition
               self.handleSuccessLogin()
           case .fail, .userCanceled:
               self.loginState = .none
           default:
               break
           }
    }
}

private extension LoginSessionLayer {
    private func handleSuccessLogin() {
        self.insertConnectionDateUpdate()
        self.setNeedUpdatePassword { [weak self] in
            self?.updateLastLoginDate(Date())
        }
        self.delegate?.willOpenSession { [weak self] in
            self?.sessionDataManager.load()
        }
    }
    
    private func setNeedUpdatePassword(_ completion: @escaping () -> Void) {
        guard let lastPass = lastPasswordLenght, lastPass != 0 else { return completion() }
        let input = SetNeedUpdatePasswordUseCaseInput(passwordLenght: lastPass,
                                                      isBiometricLogin: isBiometricLogin)
        let usecase = self.setNeedUpdatePasswordUseCase.setRequestValues(requestValues: input)
        UseCaseWrapper(with: usecase,
                       useCaseHandler: self.useCaseHandler,
                       queuePriority: .veryHigh,
                       onSuccess: { _ in completion() },
                       onError: { _ in completion() })
    }
    
    private func updateLastLoginDate(_ date: Date) {
        let input = SetLastLoginDateUseCaseInput(date: date)
        UseCaseWrapper(with: setLastLoginDateUseCase.setRequestValues(requestValues: input),
                       useCaseHandler: useCaseHandler)
    }
    
    func insertConnectionDateUpdate() {
        Scenario(useCase: self.dependenciesResolver.resolve(for: InsertConnectionDateUseCase.self))
            .execute(on: self.dependenciesResolver.resolve())
    }
}

extension LoginSessionLayer: LoginSessionStateprotocol {
    func onSuccess() {
        self.loginState = .none
        self.delegate?.onSuccess()
    }
    
    func onBloqued() {
        self.loginState = .none
        self.delegate?.onBloqued()
    }
    
    func onOtp(firsTime: Bool, userName: String?) {
        self.loginState = .none
        self.delegate?.onOtp(firsTime: firsTime, userName: self.globalPositionName)
    }
}

extension LoginSessionLayer: SessionDataManagerDelegate, SessionDataManagerProcessDelegate {
    func willLoadSession() {
        dependenciesResolver.resolve(for: PfmControllerProtocol.self).cancelAll()
    }
    
    func handleProcessEvent(_ event: SessionManagerProcessEvent) {
        switch event {
        case .loadDataSuccess:
            self.loginState = .none
            self.sessionManager.sessionStarted(completion: nil)
        case .fail, .cancelByUser:
            self.loginState = .none
        case .updateLoadingMessage(let isPb, let globalPositionName):
            self.globalPositionName = globalPositionName
        default:
            break
        }
        self.delegate?.handle(event: event)
    }
}
