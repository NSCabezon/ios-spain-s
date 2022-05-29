//
//  SetLanguageUseCase.swift
//  Onboarding
//
//  Created by Jose Camallonga on 10/12/21.
//

import Foundation
import CoreDomain
import CoreFoundationLib
import OpenCombine
import Localization

protocol SetLanguageUseCase {
    func execute(current: LanguageType, userId: String) -> AnyPublisher<Void, Never>
}

struct DefaultSetLanguageUseCase {
    private let appRepository: AppRepositoryProtocol
    private let stringLoader: StringLoader
    
    init(dependencies: OnboardingLanguagesExternalDependenciesResolver) {
        appRepository = dependencies.resolve()
        stringLoader = dependencies.resolve()
    }
}

extension DefaultSetLanguageUseCase: SetLanguageUseCase {
    func execute(current: LanguageType, userId: String) -> AnyPublisher<Void, Never> {
        let isPb = appRepository.getUserPreferences(userId: userId).isUserPb
        let language = Language.createFromType(languageType: current, isPb: isPb)
        appRepository.changeLanguage(language: current)
        stringLoader.updateCurrentLanguage(language: language)
        return Just(())            
            .eraseToAnyPublisher()
    }
}
