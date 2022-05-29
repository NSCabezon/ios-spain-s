//
//  OnboardingWelcomeDependenciesResolver.swift
//  Onboarding
//
//  Created by Jose Camallonga on 1/12/21.
//

import Foundation
import UI
import CoreFoundationLib

protocol OnboardingWelcomeDependenciesResolver {
    var external: OnboardingWelcomeExternalDependenciesResolver { get }
    func resolve() -> OnboardingWelcomeViewModel
    func resolve() -> OnboardingWelcomeViewController
    func resolve() -> GetUserInfoUseCase
    func resolve() -> DataBinding
    func resolve() -> OnboardingCoordinator
    func resolve() -> StepsCoordinator<OnboardingStep>
    func resolve() -> OnboardingLanguageManagerProtocol
}

extension OnboardingWelcomeDependenciesResolver {
    func resolve() -> OnboardingWelcomeViewModel {
        return OnboardingWelcomeViewModel(dependencies: self)
    }
    
    func resolve() -> OnboardingWelcomeViewController {
        return OnboardingWelcomeViewController(dependencies: self)
    }
    
    func resolve() -> GetUserInfoUseCase {
        return DefaultGetUserInfoUseCase(dependencies: self.external)
    }
}
