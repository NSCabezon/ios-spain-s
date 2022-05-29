//
//  FeatureFlagsViewModel.swift
//  Account
//
//  Created by José Carlos Estela Anguita on 14/3/22.
//

import UI
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

enum FeatureFlagsState: State {
    case idle
    case loaded([FeatureFlagWithValue])
}

final class FeatureFlagsViewModel {
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: FeatureFlagsDependenciesResolver
    private let stateSubject = CurrentValueSubject<FeatureFlagsState, Never>(.idle)
    private var updatedFeatures: [AnyFeatureFlag: FeatureValue] = [:]
    var state: AnyPublisher<FeatureFlagsState, Never>
    
    init(dependencies: FeatureFlagsDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        getFeatureFlagsUseCase.fetchAll()
            .map({ FeatureFlagsState.loaded($0) })
            .subscribe(stateSubject)
            .store(in: &subscriptions)
    }
    
    func featureDidUpdate(_ feature: FeatureFlagWithValue) {
        updatedFeatures[feature.feature] = feature.value
    }
    
    func save() {
        updatedFeatures
            .map({ FeatureFlagWithValue(feature: $0.key, value: $0.value) })
            .forEach(updateFeatureUseCase.update)
        dismiss()
    }
    
    func dismiss() {
        coordinator.dismiss()
    }
}

private extension FeatureFlagsViewModel {
    var getFeatureFlagsUseCase: GetFeatureFlagsUseCase {
        return dependencies.resolve()
    }
    var updateFeatureUseCase: UpdateFeatureFlagUseCase {
        return dependencies.resolve()
    }
    var coordinator: FeatureFlagsCoordinator {
        return dependencies.resolve()
    }
}
