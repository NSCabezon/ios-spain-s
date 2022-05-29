//
//  OnboardingChangeAliasDependenciesResolver.swift
//  Onboarding
//
//  Created by Jose Ignacio de Juan Díaz on 28/12/21.
//

import Foundation
import CoreFoundationLib
import UI

protocol OnboardingChangeAliasDependenciesResolver {
    var external: OnboardingChangeAliasExternalDependenciesResolver { get }
    func resolve() -> OnboardingChangeAliasViewModel
    func resolve() -> OnboardingChangeAliasViewController
    func resolve() -> DataBinding
    func resolve() -> StepsCoordinator<OnboardingStep>
    func resolve() -> OnboardingCoordinator
    func resolve() -> GetUserInfoUseCase
    func resolve() -> UpdateUserPreferencesUseCase
    func resolve() -> OnboardingLanguageManagerProtocol
}

extension OnboardingChangeAliasDependenciesResolver {
    func resolve() -> OnboardingChangeAliasViewModel {
        return OnboardingChangeAliasViewModel(dependencies: self)
    }
    
    func resolve() -> OnboardingChangeAliasViewController {
        return OnboardingChangeAliasViewController(dependencies: self)
    }
    
    func resolve() -> GetUserInfoUseCase {
        return DefaultGetUserInfoUseCase(dependencies: self.external)
    }
    
    func resolve() -> UpdateUserPreferencesUseCase {
        return DefaultUpdateUserPreferencesUseCase(dependencies: self.external)
    }
}
