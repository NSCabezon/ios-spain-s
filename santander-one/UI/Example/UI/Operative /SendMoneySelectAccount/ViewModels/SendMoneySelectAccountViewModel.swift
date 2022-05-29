//
//  SendMoneySelectAccountViewModel.swift
//  UI_Example
//
//  Created by José Carlos Estela Anguita on 5/1/22.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

enum SendMoneySelectAccountState: State {
    case idle
}

final class SendMoneySelectAccountViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: SendMoneySelectAccountDependenciesResolver
    private let stateSubject = CurrentValueSubject<SendMoneySelectAccountState, Never>(.idle)
    var state: AnyPublisher<SendMoneySelectAccountState, Never>
    
    init(dependencies: SendMoneySelectAccountDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        
    }
    
    func next() {
        let operative: SendMoneyOperative = dependencies.resolve()
        operative.next()
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
}

private extension SendMoneySelectAccountViewModel {}

// MARK: - Subscriptions

private extension SendMoneySelectAccountViewModel {}

// MARK: - Publishers

private extension SendMoneySelectAccountViewModel {}
