//
//  OnboardingGPSelectionDependenciesResolver.swift
//
//  Created by José Norberto Hidalgo Romero on 13/12/21.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine

protocol OnboardingGPSelectionDependenciesResolver {
    var external: OnboardingGPSelectionExternalDependenciesResolver { get }
    func resolve() -> OnboardingGPSelectionViewModel
    func resolve() -> OnboardingGPSelectionViewController
    func resolve() -> DataBinding
    func resolve() -> StepsCoordinator<OnboardingStep>
    func resolve() -> OnboardingCoordinator
    func resolve() -> GetUserInfoUseCase
    func resolve() -> UpdateUserPreferencesUseCase
    func resolve() -> OnboardingLanguageManagerProtocol
    func resolve() -> GetStepperValuesUseCase
}

extension OnboardingGPSelectionDependenciesResolver {
    func resolve() -> OnboardingGPSelectionViewModel {
        return OnboardingGPSelectionViewModel(dependencies: self)
    }
    
    func resolve() -> OnboardingGPSelectionViewController {
        return OnboardingGPSelectionViewController(dependencies: self)
    }
    
    func resolve() -> GetUserInfoUseCase {
        return DefaultGetUserInfoUseCase(dependencies: self.external)
    }
    
    func resolve() -> UpdateUserPreferencesUseCase {
        return DefaultUpdateUserPreferencesUseCase(dependencies: self.external)
    }
    
    func resolve() -> GetStepperValuesUseCase {
        return DefaultGetStepperValuesUseCase(stepsCoordinator: resolve(),
                                              onboardingConfiguration: external.resolve())
    }
}
