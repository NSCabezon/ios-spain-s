//
//  AnalysisAreaMovementsFilterViewModel.swift
//  Menu
//
//  Created by Miguel Ferrer Fornali on 4/4/22.
//

import UI
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

enum AnalysisAreaMovementsFilterState: State {
    case idle
    case setFiltersApplied(_ filters: AnalysisAreaFilterRepresentable)
}

final class AnalysisAreaMovementsFilterViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: AnalysisAreaMovementsFilterDependenciesResolver
    private let stateSubject = CurrentValueSubject<AnalysisAreaMovementsFilterState, Never>(.idle)
    @BindingOptional fileprivate var filtersOutsider: AnalysisAreaFilterOutsider?
    @BindingOptional fileprivate var filtesApplied: AnalysisAreaFilterRepresentable?
    var state: AnyPublisher<AnalysisAreaMovementsFilterState, Never>
    var filters: AnalysisAreaFilterRepresentable?
    
    init(dependencies: AnalysisAreaMovementsFilterDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        guard let filters = filtesApplied else {
            return
        }
        stateSubject.send(.setFiltersApplied(filters))
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
}

extension AnalysisAreaMovementsFilterViewModel {
    func didTapCloseButton() {
        coordinator.back()
    }
    
    func didTapApply(_ data: AnalysisAreaFilterRepresentable) {
        filtersOutsider?.send(data)
        coordinator.back()
    }
}

private extension AnalysisAreaMovementsFilterViewModel {
    var coordinator: AnalysisAreaMovementsFilterCoordinator {
        return dependencies.resolve()
    }
}

// MARK: - Subscriptions
private extension AnalysisAreaMovementsFilterViewModel {}

// MARK: - Publishers
private extension AnalysisAreaMovementsFilterViewModel {}
