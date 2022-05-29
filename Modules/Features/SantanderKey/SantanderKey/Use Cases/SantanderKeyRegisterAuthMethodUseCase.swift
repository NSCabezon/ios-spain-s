//
//  SantanderKeyRegisterAuthMethodUseCase.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 10/3/22.
//

import OpenCombine
import CoreDomain
import SANSpainLibrary
import CoreFoundationLib
import ESCommons

public protocol SantanderKeyRegisterAuthMethodUseCase {
    func registerGetAuthMethod() -> AnyPublisher<(SantanderKeyRegisterAuthMethodResultRepresentable, SignatureRepresentable), Error>
}

struct DefaultSantanderKeyRegisterAuthMethodUseCase: SantanderKeyRegisterAuthMethodUseCase {
    private var repository: SantanderKeyOnboardingRepository
    private var compilation: SpainCompilationProtocol
    
    init(dependencies: SKExternalDependenciesResolver) {
        self.repository = dependencies.resolve()
        self.compilation = dependencies.resolve()
    }

    func registerGetAuthMethod() -> AnyPublisher<(SantanderKeyRegisterAuthMethodResultRepresentable, SignatureRepresentable), Error> {
        return repository.registerGetAuthMethodReactive()
            .eraseToAnyPublisher()
    }
}
