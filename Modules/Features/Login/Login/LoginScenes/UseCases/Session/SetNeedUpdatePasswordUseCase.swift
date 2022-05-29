//
//  SetNeedUpdatePasswordUseCase.swift
//  Login
//
//  Created by Juan Carlos López Robles on 11/20/20.
//

import Foundation
import SANLibraryV3
import CoreFoundationLib

public protocol SetSetNeedUpdatePasswordDelegateProtocol {
    func register(_ forceToUpdatePassword: Bool)
}

final class SetNeedUpdatePasswordUseCase: UseCase<SetNeedUpdatePasswordUseCaseInput, Void, StringErrorOutput> {
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    private let appConfig: AppConfigRepositoryProtocol
    private let passwordLengthLimit = 8
    
    init(dependenciesEngine: DependenciesResolver & DependenciesInjector) {
        self.dependenciesEngine = dependenciesEngine
        self.appConfig = self.dependenciesEngine.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    var delegate: SetSetNeedUpdatePasswordDelegateProtocol? {
        self.dependenciesEngine.resolve(forOptionalType: SetSetNeedUpdatePasswordDelegateProtocol.self)
    }
    
    override func executeUseCase(requestValues: SetNeedUpdatePasswordUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        guard let activeForceUpdate = self.appConfig.getBool(LoginConstants.forceUpdateKeys),
            activeForceUpdate == true
            else {
                register(false)
                return .ok()
        }
        if requestValues.isBiometricLogin {
            register(false)
            return .ok()
        }
        register(requestValues.passwordLenght < passwordLengthLimit)
        return .ok()
    }
}

// CHECK IN APP WHERE RESOLVE SetNeedUpdatePasswordConfiguration AND CHANGE FOR LOGIN USE CASE
private extension SetNeedUpdatePasswordUseCase {
    func register(_ forceToUpdatePassword: Bool) {
        self.delegate?.register(forceToUpdatePassword)
    }
}

public struct SetNeedUpdatePasswordUseCaseInput {
    let passwordLenght: Int
    let isBiometricLogin: Bool
}
