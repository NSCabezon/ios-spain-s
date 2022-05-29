//
//  SKSecondStepOnboardingDependenciesResolver.swift
//  SantanderKey
//
//  Created by Andres Aguirre Juarez on 27/1/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol SKSecondStepOnboardingDependenciesResolver {
    var external: SKSecondStepOnboardingExternalDependenciesResolver { get }
    func resolve() -> SKSecondStepOnboardingViewModel
    func resolve() -> SKSecondStepOnboardingViewController
    func resolve() -> SKSecondStepOnboardingCoordinator
    func resolve() -> DataBinding
}

extension SKSecondStepOnboardingDependenciesResolver {
    
    func resolve() -> SKSecondStepOnboardingViewController {
        return SKSecondStepOnboardingViewController(dependencies: self)
    }
    
    func resolve() -> SKSecondStepOnboardingViewModel {
        return SKSecondStepOnboardingViewModel(dependencies: self)
    }
}
