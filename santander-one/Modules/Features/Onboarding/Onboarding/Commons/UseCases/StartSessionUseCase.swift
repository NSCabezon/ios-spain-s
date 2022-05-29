//
//  StartSessionUseCase.swift
//  Onboarding
//
//  Created by Jose Camallonga on 10/12/21.
//

import Foundation
import OpenCombine
import CoreFoundationLib

protocol StartSessionUseCase {
    func execute() -> AnyPublisher<Void, Error>
}

class DefaultStartSessionUseCase {
    private let coreSessionManager: CoreSessionManager
    private let stateSubject = PassthroughSubject<Void, Error>()
    
    init(dependencies: OnboardingLanguagesExternalDependenciesResolver) {
        coreSessionManager = dependencies.resolve()
    }
}

extension DefaultStartSessionUseCase: StartSessionUseCase {
    func execute() -> AnyPublisher<Void, Error> {
        coreSessionManager.sessionStarted(completion: { [weak self] in
            self?.stateSubject.send()
        })
        return stateSubject
            .eraseToAnyPublisher()
    }
}
