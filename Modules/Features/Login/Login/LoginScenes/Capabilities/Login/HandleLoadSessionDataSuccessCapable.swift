//
//  HandleLoadSessionDataSuccessCapable.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/2/20.
//

import Foundation
import CoreFoundationLib
import LoginCommon
import Dynatrace

protocol HandleLoadSessionDataSuccessCapable: class {
    var loginView: LoginViewCapable? { get }
    var dependenciesResolver: DependenciesResolver { get }
    var coordinatorDelegate: LoginCoordinatorDelegate { get }
}

extension HandleLoadSessionDataSuccessCapable {
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    private var getUserPrefEntityUseCase: GetUserPrefEntityUseCase {
        return self.dependenciesResolver.resolve(for: GetUserPrefEntityUseCase.self)
    }
    private var pinPointTrusteerUseCase: PinPointTrusteerUseCase {
        return self.dependenciesResolver.resolve(for: PinPointTrusteerUseCase.self)
    }
    private var getUserFUseCase: GetUserFUseCase {
        return self.dependenciesResolver.resolve(for: GetUserFUseCase.self)
    }
    
    private func identifyUser(_ userId: String?) {
        Dynatrace.identifyUser(userId)
    }
    
    func handleLoadSessionDataSuccess() {
        UseCaseWrapper(
            with: getUserFUseCase,
            useCaseHandler: useCaseHandler,
            onSuccess: { [weak self] result in
                self?.identifyUser(result.userF)
            }
        )
        UseCaseWrapper(
            with: self.getUserPrefEntityUseCase,
            useCaseHandler: useCaseHandler,
            onSuccess: { [weak self] result in
                self?.loginView?.dismissLoading()
                let globalPositionOption = result.userPref?.globalPositionOnboardingSelected() ?? .classic
                self?.coordinatorDelegate.goToPrivate(globalPositionOption: globalPositionOption)
            }, onError: { [weak self] (_) in
                self?.loginView?.dismissLoading()
                self?.coordinatorDelegate.goToPrivate(globalPositionOption: .classic)
        })
        UseCaseWrapper(with: self.pinPointTrusteerUseCase,
                       useCaseHandler: self.useCaseHandler)
    }
}
