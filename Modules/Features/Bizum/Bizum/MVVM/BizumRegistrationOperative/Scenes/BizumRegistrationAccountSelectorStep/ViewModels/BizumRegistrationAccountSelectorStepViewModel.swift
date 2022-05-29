//
//  BizumRegistrationAccountSelectorStepViewModel.swift
//  Bizum
//
//  Created by Tania Castellano Brasero on 25/4/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

enum BizumRegistrationAccountSelectorStepState: State {
    case idle
}

final class BizumRegistrationAccountSelectorStepViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: BizumRegistrationAccountSelectorStepDependenciesResolver
    private let stateSubject = CurrentValueSubject<BizumRegistrationAccountSelectorStepState, Never>(.idle)
    var state: AnyPublisher<BizumRegistrationAccountSelectorStepState, Never>
    
    init(dependencies: BizumRegistrationAccountSelectorStepDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
}

private extension BizumRegistrationAccountSelectorStepViewModel {}

// MARK: - Subscriptions

private extension BizumRegistrationAccountSelectorStepViewModel {}

// MARK: - Publishers

private extension BizumRegistrationAccountSelectorStepViewModel {}
