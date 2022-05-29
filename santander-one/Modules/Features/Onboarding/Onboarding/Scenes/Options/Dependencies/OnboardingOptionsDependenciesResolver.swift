//
//  OnboardingOptionsDependenciesResolver.swift
//  Onboarding
//
//  Created by Jose Hidalgo on 07/01/22.
//

import Foundation
import UI
import CoreFoundationLib

protocol OnboardingOptionsDependenciesResolver {
    var external: OnboardingOptionsExternalDependenciesResolver { get }
    func resolve() -> OnboardingOptionsViewModel
    func resolve() -> OnboardingOptionsViewController
    func resolve() -> GetUserInfoUseCase
    func resolve() -> GetOnboardingPermissionsUseCase
    func resolve() -> DataBinding
    func resolve() -> StepsCoordinator<OnboardingStep>
    func resolve() -> OnboardingCoordinator
    func resolve() -> GetStepperValuesUseCase
}

extension OnboardingOptionsDependenciesResolver {
    func resolve() -> OnboardingOptionsViewModel {
        return OnboardingOptionsViewModel(dependencies: self)
    }
    
    func resolve() -> OnboardingOptionsViewController {
        return OnboardingOptionsViewController(dependencies: self)
    }
    
    func resolve() -> GetOnboardingPermissionsUseCase {
        return DefaultGetOnboardingPermissionsUseCase(dependencies: external)
    }
    
    func resolve() -> GetUserInfoUseCase {
        return DefaultGetUserInfoUseCase(dependencies: external)
    }
    func resolve() -> GetStepperValuesUseCase {
        return DefaultGetStepperValuesUseCase(stepsCoordinator: resolve(),
                                              onboardingConfiguration: external.resolve())
    }
}
