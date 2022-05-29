//
//  OnboardingDependenciesResolver.swift
//  Transfer
//
//  Created by Andres Aguirre Juarez on 27/1/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol SKFirstStepOnboardingDependenciesResolver {
    var external: SKFirstStepOnboardingExternalDependenciesResolver { get }
    func resolve() -> SKFirstStepOnboardingViewModel
    func resolve() -> SKFirstStepOnboardingViewController
    func resolve() -> SKFirstStepOnboardingCoordinator
    func resolve() -> DataBinding
}

extension SKFirstStepOnboardingDependenciesResolver {
    func resolve() -> SKFirstStepOnboardingViewController {
        return SKFirstStepOnboardingViewController(dependencies: self)
    }
    
    func resolve() -> SKFirstStepOnboardingViewModel {
        return SKFirstStepOnboardingViewModel(dependencies: self)
    }
}
