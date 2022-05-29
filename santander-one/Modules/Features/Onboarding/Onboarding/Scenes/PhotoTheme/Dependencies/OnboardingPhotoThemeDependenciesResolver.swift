//
//  OnboardingPhotoThemeDependenciesResolver.swift
//  Onboarding
//
//  Created by Jose Camallonga on 15/12/21.
//

import Foundation
import UI
import CoreFoundationLib

protocol OnboardingPhotoThemeDependenciesResolver {
    var external: OnboardingPhotoThemeExternalDependenciesResolver { get }
    func resolve() -> OnboardingPhotoThemeViewModel
    func resolve() -> OnboardingPhotoThemeViewController
    func resolve() -> GetUserInfoUseCase
    func resolve() -> LoadBackgroundImagesUseCase
    func resolve() -> DataBinding
    func resolve() -> StepsCoordinator<OnboardingStep>
    func resolve() -> OnboardingCoordinator
    func resolve() -> GetStepperValuesUseCase
}

extension OnboardingPhotoThemeDependenciesResolver {
    func resolve() -> OnboardingPhotoThemeViewModel {
        return OnboardingPhotoThemeViewModel(dependencies: self)
    }
    
    func resolve() -> OnboardingPhotoThemeViewController {
        return OnboardingPhotoThemeViewController(dependencies: self)
    }
    
    func resolve() -> GetUserInfoUseCase {
        return DefaultGetUserInfoUseCase(dependencies: self.external)
    }
    
    func resolve() -> LoadBackgroundImagesUseCase {
        return DefaultLoadBackgroundImagesUseCase(dependencies: self.external)
    }
    
    func resolve() -> GetStepperValuesUseCase {
        return DefaultGetStepperValuesUseCase(stepsCoordinator: resolve(),
                                              onboardingConfiguration: external.resolve())
    }
}
