//
//  SKSecondStepOnboardingViewModel.swift
//  SantanderKey
//
//  Created by Andres Aguirre Juarez on 27/1/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

enum SKSecondStepOnboardingState: State {
    case idle
}

final class SKSecondStepOnboardingViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: SKSecondStepOnboardingDependenciesResolver
    private let stateSubject = CurrentValueSubject<SKSecondStepOnboardingState, Never>(.idle)
    var state: AnyPublisher<SKSecondStepOnboardingState, Never>

    init(dependencies: SKSecondStepOnboardingDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {}
    
    func didSelectOneFloatingButton() {
        coordinator.goToGlobalPosition()
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    func didSelectSantanderConfiguration() {
    }
}

private extension SKSecondStepOnboardingViewModel {
    var coordinator: SKSecondStepOnboardingCoordinator {
        return dependencies.resolve()
    }
}

// MARK: - Subscriptions

private extension SKSecondStepOnboardingViewModel {}

// MARK: - Publishers

private extension SKSecondStepOnboardingViewModel {}
