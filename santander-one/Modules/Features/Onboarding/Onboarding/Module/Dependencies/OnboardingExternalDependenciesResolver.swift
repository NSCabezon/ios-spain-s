//
//  OnboardingExternalDependenciesResolver.swift
//  Onboarding
//
//  Created by Jose Ignacio de Juan Díaz on 2/12/21.
//

import Foundation
import CoreDomain
import UIKit
import UI

public protocol OnboardingExternalDependenciesResolver: OnboardingWelcomeExternalDependenciesResolver,
                                                        OnboardingChangeAliasExternalDependenciesResolver,
                                                        OnboardingOptionsExternalDependenciesResolver,
                                                        OnboardingGPSelectionExternalDependenciesResolver,
                                                        OnboardingLanguagesExternalDependenciesResolver,
                                                        OnboardingPhotoThemeExternalDependenciesResolver,
                                                        OnboardingFinalExternalDependenciesResolver {
    func onboardingCoordinator() -> BindableCoordinator
    func resolve() -> UINavigationController
    func resolveOnBoardingCustomStepView(for identifier: String, coordinator: StepsCoordinator<OnboardingStep>) -> StepIdentifiable
}

public extension OnboardingExternalDependenciesResolver {
    func onboardingCoordinator() -> BindableCoordinator {
        return OnboardingCoordinator(dependencies: self, navigationController: resolve())
    }
}
