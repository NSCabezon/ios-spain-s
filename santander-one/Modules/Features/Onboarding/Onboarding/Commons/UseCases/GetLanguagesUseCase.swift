//
//  GetLanguagesUseCase.swift
//  Onboarding
//
//  Created by Jose Camallonga on 10/12/21.
//

import Foundation
import CoreFoundationLib
import OpenCombine

protocol GetLanguagesUseCase {
    func fetch() -> AnyPublisher<[LanguageType], Error>
}

struct DefaultGetLanguagesUseCase {
    private let appConfig: LocalAppConfig
    
    init(dependencies: OnboardingLanguagesExternalDependenciesResolver) {
        appConfig = dependencies.resolve()
    }
}

extension DefaultGetLanguagesUseCase: GetLanguagesUseCase {
    func fetch() -> AnyPublisher<[LanguageType], Error> {
        Just(appConfig.languageList)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
