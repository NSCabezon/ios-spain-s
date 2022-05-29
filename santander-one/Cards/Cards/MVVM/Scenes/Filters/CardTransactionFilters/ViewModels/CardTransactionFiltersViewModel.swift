//
//  CardTransactionFiltersViewModel.swift
//  Cards
//
//  Created by José Carlos Estela Anguita on 19/4/22.
//

import UI
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

enum CardTransactionFiltersState: State {
    case idle
    case availableFiltersLoaded(CardTransactionAvailableFiltersRepresentable)
    case filtersLoaded([CardTransactionFilterType])
}

private struct CardTransactionFilters: CardTransactionFiltersRepresentable {
    var cardFilters: [CardTransactionFilterType]
}

final class CardTransactionFiltersViewModel: DataBindable {
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: CardTransactionFiltersDependenciesResolver
    private let stateSubject = CurrentValueSubject<CardTransactionFiltersState, Never>(.idle)
    var state: AnyPublisher<CardTransactionFiltersState, Never>
    @BindingOptional var card: CardRepresentable?
    @BindingOptional var outsider: CardTransactionFilterOutsider?
    @BindingOptional var currentFilters: [CardTransactionFilterType]? 
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    init(dependencies: CardTransactionFiltersDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func dismiss() {
        coordinator.dismiss()
    }
    
    func viewDidLoad() {
        self.trackScreen()
        availableFiltersUseCase.fetchAvailableFiltersPublisher()
            .sink { [unowned self] filters in
                self.stateSubject.send(.availableFiltersLoaded(filters))
            }
            .store(in: &subscriptions)
        
        guard let currentFilters = self.currentFilters else {
            return
        }
        self.stateSubject.send(.filtersLoaded(currentFilters))
    }
    
    func save(filters: [CardTransactionFilterType]) {
        guard let card = card else { return }
        validator.fetchFiltersPublisher(given: filters, card: card)
            .sink { filters in
                self.outsider?.send(CardTransactionFilters(cardFilters: filters))
                self.coordinator.dismiss()
            }
            .store(in: &subscriptions)
    }
    
}

private extension CardTransactionFiltersViewModel {
    var validator: CardTransactionFilterValidator {
        return dependencies.external.resolve()
    }
}

// MARK: - Subscriptions

private extension CardTransactionFiltersViewModel {
    var coordinator: CardTransactionFiltersCoordinator {
        return dependencies.resolve()
    }
    var availableFiltersUseCase: CardTransactionAvailableFiltersUseCase {
        return dependencies.external.resolve()
    }
}

extension CardTransactionFiltersViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependencies.external.resolve()
    }
    var trackerPage: CardsSearchPage {
        return CardsSearchPage()
    }
}

