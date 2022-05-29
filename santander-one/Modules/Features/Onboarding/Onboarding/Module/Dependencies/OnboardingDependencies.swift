//
//  OnboardingDependencies.swift
//  Onboarding
//
//  Created by Jose Ignacio de Juan Díaz on 28/12/21.
//

import Foundation
import UI
import CoreFoundationLib

protocol OnboardingDependencies {
    var external: OnboardingExternalDependenciesResolver { get }
    func resolve() -> OnboardingCoordinator
    func resolve() -> StepsCoordinator<OnboardingStep>
    func resolve() -> DataBinding
    func resolve() -> OnboardingWelcomeViewController
    func resolve() -> OnboardingChangeAliasViewController
    func resolve() -> OnboardingOptionsViewController
    func resolve() -> OnboardingGPSelectionViewController
    func resolve() -> OnboardingLanguagesViewController
    func resolve() -> OnboardingPhotoThemeViewController
    func resolve() -> OnboardingFinalViewController
    func resolve() -> OnboardingLanguageManagerProtocol
}

extension OnboardingDependencies {
    func resolve() -> OnboardingWelcomeViewController {
        return OnboardingWelcomeDependencies(dependencies: self).resolve()
    }
    func resolve() -> OnboardingChangeAliasViewController {
        return OnboardingChangeAliasDependencies(dependencies: self).resolve()
    }
    func resolve() -> OnboardingOptionsViewController {
        return OnboardingOptionsDependencies(dependencies: self).resolve()
    }
    func resolve() -> OnboardingGPSelectionViewController {
        return OnboardingGPSelectionDependencies(dependencies: self).resolve()
    }
    func resolve() -> OnboardingLanguagesViewController {
        return OnboardingLanguagesDependencies(dependencies: self).resolve()
    }
    func resolve() -> OnboardingPhotoThemeViewController {
        return OnboardingPhotoThemeDependencies(dependencies: self).resolve()
    }
    func resolve() -> OnboardingFinalViewController {
        return OnboardingFinalDependencies(dependencies: self).resolve()
    }
}
