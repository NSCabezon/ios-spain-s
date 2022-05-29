//
//  OnboardingLanguagesDependenciesResolver.swift
//  Onboarding
//
//  Created by Jose Camallonga on 9/12/21.
//

import Foundation
import UI
import CoreFoundationLib

protocol OnboardingLanguagesDependenciesResolver {
    var external: OnboardingLanguagesExternalDependenciesResolver { get }
    func resolve() -> OnboardingLanguagesViewModel
    func resolve() -> OnboardingLanguagesViewController
    func resolve() -> StepsCoordinator<OnboardingStep>
    func resolve() -> OnboardingCoordinator
    func resolve() -> GetLanguagesUseCase
    func resolve() -> GetUserInfoUseCase
    func resolve() -> GetUserLanguageUseCase
    func resolve() -> LoadPublicFilesUseCase
    func resolve() -> LoadSessionDataUseCase
    func resolve() -> SetLanguageUseCase
    func resolve() -> StartSessionUseCase
    func resolve() -> DataBinding
    func resolve() -> OnboardingLanguageManagerProtocol
    func resolve() -> GetStepperValuesUseCase
}

extension OnboardingLanguagesDependenciesResolver {
    func resolve() -> OnboardingLanguagesViewModel {
        return OnboardingLanguagesViewModel(dependencies: self)
    }
    
    func resolve() -> OnboardingLanguagesViewController {
        return OnboardingLanguagesViewController(dependencies: self)
    }
    
    func resolve() -> GetLanguagesUseCase {
        return DefaultGetLanguagesUseCase(dependencies: self.external)
    }
    
    func resolve() -> GetUserInfoUseCase {
        return DefaultGetUserInfoUseCase(dependencies: self.external)
    }
    
    func resolve() -> GetUserLanguageUseCase {
        return DefaultGetUserLanguageUseCase(dependencies: self.external)
    }
    
    func resolve() -> LoadPublicFilesUseCase {
        return DefaultLoadPublicFilesUseCase(dependencies: self.external)
    }
    
    func resolve() -> LoadSessionDataUseCase {
        return DefaultLoadSessionDataUseCase(dependencies: self.external)
    }
    
    func resolve() -> SetLanguageUseCase {
        return DefaultSetLanguageUseCase(dependencies: self.external)
    }
    
    func resolve() -> StartSessionUseCase {
        return DefaultStartSessionUseCase(dependencies: self.external)
    }
    
    func resolve() -> GetStepperValuesUseCase {
        return DefaultGetStepperValuesUseCase(stepsCoordinator: resolve(),
                                              onboardingConfiguration: external.resolve())
    }
}
