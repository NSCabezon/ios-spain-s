//
//  SKCardSelectorDependenciesResolver.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 24/2/22.
//

import UI
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib
import UIOneComponents
import SANSpainLibrary

enum CardSelectorState: State {
    case idle
    case cardsLoaded([SKCardModel])
    case cardSelected((SKCardModel, Int))
}

final class SKCardSelectorViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: SKCardSelectorDependenciesResolver
    private let stateSubject = CurrentValueSubject<CardSelectorState, Never>(.idle)
    var state: AnyPublisher<CardSelectorState, Never>
    var stepsCoordinator: StepsCoordinator<SKOperativeStep>?
    private var selectedCard: (SKCardModel, Int)?
    @BindingOptional var operativeData: SKOnboardingOperativeData!
    var cardList: [SKCardModel] = []

    
    init(dependencies: SKCardSelectorDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        stepsCoordinator = operative.stepsCoordinator
        if let clientCards = operativeData.cardList as? [SantanderKeyCardRepresentable] {
            cardList = clientCards.map(SKCardModel.init)
            stateSubject.send(.cardsLoaded(cardList))
        }
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    @objc func didTapContinueButton() {
        guard let selectedCard = selectedCard,
              let pan = selectedCard.0.pan,
              let type = selectedCard.0.cardType
        else { return }

        operativeData.selectedCardPAN = pan
        operativeData.cardType = type
        dataBinding.set(operativeData)
        operative.coordinator.next()
    }
    
    func didTappedCardAt(row: Int) {
        guard row != selectedCard?.1 else { return }
            guard row < cardList.count else { return }
            if var selectedCard = selectedCard {
                selectedCard.0.cardStatus = .normal
                stateSubject.send(.cardSelected((selectedCard.0, selectedCard.1)))
            }
            
            var clientCard = cardList[row]
            clientCard.cardStatus = .selected
            selectedCard = (clientCard, row)
            
            guard let selectedCard = selectedCard else { return }
            stateSubject.send(.cardSelected((selectedCard.0, row)))
    }
}

private extension SKCardSelectorViewModel {
    var operative: SKOperative {
        dependencies.resolve()
    }
}

// MARK: - Subscriptions

private extension SKCardSelectorViewModel {

}

// MARK: - Publishers

private extension SKCardSelectorViewModel {

}
