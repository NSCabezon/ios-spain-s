//
//  SetNeedUpdatePasswordUseCase.swift
//  RetailClean
//
//  Created by alvola on 01/10/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class SetNeedUpdatePasswordUseCase: UseCase<SetNeedUpdatePasswordUseCaseInput, Void, StringErrorOutput> {
    private let appConfigRepository: AppConfigRepository
    private let dependenciesEngine: DependenciesInjector & DependenciesResolver
    private let passwordLengthLimit = 6
    
    init(dependenciesEngine: DependenciesInjector & DependenciesResolver, appConfigRepository: AppConfigRepository) {
        self.dependenciesEngine = dependenciesEngine
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: SetNeedUpdatePasswordUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        guard let activeForceUpdate = appConfigRepository.getBool(DomainConstant.forceUpdateKeys),
            activeForceUpdate == true
            else {
                register(false)
                return .ok()
        }
        register(requestValues.passwordLenght <= passwordLengthLimit)
        return .ok()
    }
}

private extension SetNeedUpdatePasswordUseCase {
    func register(_ forceToUpdatePassword: Bool) {
        let configuration = SetNeedUpdatePasswordConfiguration(forceToUpdatePassword: forceToUpdatePassword)
        dependenciesEngine.register(for: SetNeedUpdatePasswordConfiguration.self) { _ in
            return configuration
        }
    }
}

struct SetNeedUpdatePasswordUseCaseInput {
    let passwordLenght: Int
}

struct SetNeedUpdatePasswordConfiguration {
    let forceToUpdatePassword: Bool
}
