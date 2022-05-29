//
//  BizumRegistrationViewModel.swift
//  Bizum
//
//  Created by Tania Castellano Brasero on 11/4/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

enum BizumRegistrationState: State {
    case idle
}

final class BizumRegistrationViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: BizumRegistrationDependenciesResolver
    private let stateSubject = CurrentValueSubject<BizumRegistrationState, Never>(.idle)
    var state: AnyPublisher<BizumRegistrationState, Never>
    
    init(dependencies: BizumRegistrationDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        trackScreen()
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    func startRegistration() {
        dependencies.resolve().goToRegistrationOperative()
    }
    
    func trackScreen() {
        trackerManager.trackScreen(screenId: trackerPage.page, extraParameters: [:])
    }
}

private extension BizumRegistrationViewModel {
    var coordinator: BizumRegistrationCoordinator {
        return dependencies.resolve()
    }
}

// MARK: - Subscriptions

private extension BizumRegistrationViewModel {}

// MARK: - Publishers

private extension BizumRegistrationViewModel {}

extension BizumRegistrationViewModel {
    func didTapCloseButton() {
        coordinator.dismiss()
    }
}

extension BizumRegistrationViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }

    var trackerPage: BizumRegistrationPage {
        BizumRegistrationPage()
    }
}
