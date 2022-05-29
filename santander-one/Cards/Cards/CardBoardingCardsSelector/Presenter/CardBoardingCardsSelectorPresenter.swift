//
//  CardBoardingCardsSelectorPresenterPresenter.swift
//  Pods
//
//  Created by Boris Chirino Fernandez on 19/01/2021.
//  

import CoreFoundationLib

protocol CardBoardingCardsSelectorPresenterProtocol: AnyObject {
    var view: CardBoardingCardsSelectorPresenterViewProtocol? { get set }
    func didTapBack()
    func didTapClose()
    func getCardsViewModel() -> [CardboardingCardCellViewModel]
    func didSelectItem(_ viewModel: CardboardingCardCellViewModel)
}

final class CardBoardingCardsSelectorPresenter {
    weak var view: CardBoardingCardsSelectorPresenterViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    var configuration: CardBoardingCardsSelectorConfiguration

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.configuration = dependenciesResolver.resolve(for: CardBoardingCardsSelectorConfiguration.self)
    }
}

private extension CardBoardingCardsSelectorPresenter {
    var coordinator: CardBoardingCardsSelectorCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: CardBoardingCardsSelectorCoordinatorProtocol.self)
    }
    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    var baseUrlProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
}

extension CardBoardingCardsSelectorPresenter: CardBoardingCardsSelectorPresenterProtocol {
    func didSelectItem(_ viewModel: CardboardingCardCellViewModel) {
        guard let selectedCard = self.configuration.cards.filter({viewModel.isInstanceEntityEqualTo($0)}).first else {
            return
        }
        self.coordinator.didSelectCardEntity(card: selectedCard)
    }
    
    func getCardsViewModel() -> [CardboardingCardCellViewModel] {
        let baseUrl = self.baseUrlProvider.baseURL ?? ""
        let result =  self.configuration.cards.map { cardEntity in
            CardboardingCardCellViewModel(cardEntity: cardEntity, baseUrl: baseUrl)
        }
        return result
    }
    
    func didTapBack() {
        self.coordinator.back()
    }
    
    func didTapClose() {
        self.coordinator.closeCardsSelector()
    }
}
