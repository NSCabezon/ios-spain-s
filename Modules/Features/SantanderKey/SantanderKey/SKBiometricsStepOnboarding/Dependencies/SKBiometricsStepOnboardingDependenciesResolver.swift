//
//  SKBiometricsStepOnboardingDependenciesResolver.swift
//  SantanderKey
//
//  Created by Tania Castellano Brasero on 24/2/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol SKBiometricsStepOnboardingDependenciesResolver {
    var external: SKBiometricsStepOnboardingExternalDependenciesResolver { get }
    func resolve() -> SKBiometricsStepOnboardingViewModel
    func resolve() -> SKBiometricsStepOnboardingViewController
    func resolve() -> SKBiometricsStepOnboardingCoordinator
    func resolve() -> DataBinding
}

extension SKBiometricsStepOnboardingDependenciesResolver {
    
    func resolve() -> SKBiometricsStepOnboardingViewController {
        return SKBiometricsStepOnboardingViewController(dependencies: self)
    }
    
    func resolve() -> SKBiometricsStepOnboardingViewModel {
        return SKBiometricsStepOnboardingViewModel(dependencies: self)
    }
}
