//
//  GetUserLanguageUseCase.swift
//  Onboarding
//
//  Created by Jose Camallonga on 7/1/22.
//

import Foundation
import CoreDomain
import CoreFoundationLib
import OpenCombine

protocol GetUserLanguageUseCase {
    func fetch(userId: String) -> AnyPublisher<Language, Error>
}

struct DefaultGetUserLanguageUseCase {
    private let appRepository: AppRepositoryProtocol
    private let appConfig: LocalAppConfig
    
    init(dependencies: OnboardingLanguagesExternalDependenciesResolver) {
        appRepository = dependencies.resolve()
        appConfig = dependencies.resolve()
    }
}

extension DefaultGetUserLanguageUseCase: GetUserLanguageUseCase {
    func fetch(userId: String) -> AnyPublisher<Language, Error> {
        let isUserPb = appRepository.getUserPreferences(userId: userId).isUserPb
        let languageType = appRepository.getCurrentLanguage()
        return Just(Language.createFromType(languageType: languageType, isPb: isUserPb))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
