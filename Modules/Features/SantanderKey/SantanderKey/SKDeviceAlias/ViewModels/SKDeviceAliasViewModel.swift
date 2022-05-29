//
//  SKDeviceAliasViewModel.swift
//  SantanderKey
//
//  Created by Andres Aguirre Juarez on 15/2/22.
//

import UI
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib
import UIKit
import UIOneComponents

enum SKDeviceAliasState: State {
    case idle
    case textfFieldEmpty(Bool)
}

final class SKDeviceAliasViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: SKDeviceAliasDependenciesResolver
    private let stateSubject = CurrentValueSubject<SKDeviceAliasState, Never>(.idle)
    var state: AnyPublisher<SKDeviceAliasState, Never>
    var stepsCoordinator: StepsCoordinator<SKOperativeStep>?
    @BindingOptional var operativeData: SKOnboardingOperativeData!
    
    init(dependencies: SKDeviceAliasDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        stepsCoordinator = operative.stepsCoordinator
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    func setTextfieldEmpty(_ empty: Bool) {
        stateSubject.send(.textfFieldEmpty(empty))
    }
    
    func didTapContinueButton(alias: String) {
        operativeData.alias = alias
        dataBinding.set(operativeData)
        operative.coordinator.next()
    }
}

private extension SKDeviceAliasViewModel {
    var operative: SKOperative {
        dependencies.resolve()
    }
}

// MARK: - Subscriptions

private extension SKDeviceAliasViewModel {}

// MARK: - Publishers

private extension SKDeviceAliasViewModel {
    
}
