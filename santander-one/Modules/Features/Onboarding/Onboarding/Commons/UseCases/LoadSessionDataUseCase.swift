//
//  LoadSessionDataUseCase.swift
//  Onboarding
//
//  Created by Jose Camallonga on 10/12/21.
//

import Foundation
import OpenCombine
import CoreFoundationLib

protocol LoadSessionDataUseCase {
    func execute() -> AnyPublisher<SessionManagerProcessEvent, Error>
}

class DefaultLoadSessionDataUseCase {
    private let sessionDataManager: SessionDataManager
    
    init(dependencies: OnboardingLanguagesExternalDependenciesResolver) {
        sessionDataManager = dependencies.resolve()
    }
}

extension DefaultLoadSessionDataUseCase: LoadSessionDataUseCase {
    func execute() -> AnyPublisher<SessionManagerProcessEvent, Error> {
        sessionDataManager.setDataManagerProcessDelegate(nil)
        sessionDataManager.load()
        return sessionDataManager.event
    }
}
