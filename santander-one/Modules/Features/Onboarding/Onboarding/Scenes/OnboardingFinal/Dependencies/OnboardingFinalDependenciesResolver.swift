//
//  OnboardingFinalDependenciesResolver.swift
//  Onboarding
//
//  Created by José Norberto Hidalgo Romero on 21/12/21.
//

import UI
import Foundation
import CoreFoundationLib
import CoreDomain
import OpenCombine

protocol OnboardingFinalDependenciesResolver {
    var external: OnboardingFinalExternalDependenciesResolver { get }
    func resolve() -> OnboardingFinalViewModel
    func resolve() -> OnboardingFinalViewController
    func resolve() -> GetUserInfoUseCase
    func resolve() -> StepsCoordinator<OnboardingStep>
    func resolve() -> OnboardingCoordinator
    func resolve() -> DataBinding
}

extension OnboardingFinalDependenciesResolver {
    func resolve() -> OnboardingFinalViewModel {
        return OnboardingFinalViewModel(dependencies: self)
    }
    
    func resolve() -> OnboardingFinalViewController {
        return OnboardingFinalViewController(dependencies: self)
    }
    
    func resolve() -> GetUserInfoUseCase {
        return DefaultGetUserInfoUseCase(dependencies: external)
    }
}
