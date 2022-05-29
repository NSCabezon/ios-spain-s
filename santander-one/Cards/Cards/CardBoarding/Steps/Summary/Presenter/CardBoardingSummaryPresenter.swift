//
//  SummaryPresenter.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/14/20.
//
import CoreFoundationLib
import Foundation

protocol CardBoardingSummaryPresenterProtocol {
    var view: CardBoardingSummaryViewProtocol? { get set }
    func viewDidLoad()
    func didSelectMyCards()
    func didSelectGlobalPosition()
    func didSelectImprove()
}

final class CardBoardingSummaryPresenter {
    private let dependenciesResolver: DependenciesResolver
    weak var view: CardBoardingSummaryViewProtocol?
    
    private var coordinator: CardBoardingCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: CardBoardingCoordinatorProtocol.self)
    }
    private var coordinatorDelegate: CardBoardingCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: CardBoardingCoordinatorDelegate.self)
    }
    private var configuration: CardboardingConfiguration {
        return dependenciesResolver.resolve(for: CardboardingConfiguration.self)
    }
    private var cardBoardingStepTracker: CardBoardingStepTracker {
        return self.dependenciesResolver.resolve(for: CardBoardingStepTracker.self)
    }
    private var cardColorsArray: [CardTextColorEntity] {
        self.dependenciesResolver.resolve(for: [CardTextColorEntity].self)
    }
    private var urlProvider: BaseURLProvider {
        self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func viewDidLoad() {
        let card = configuration.selectedCard
        let viewModel = PlasticCardViewModel(
            entity: card,
            textColorEntity: cardColorsArray,
            baseUrl: urlProvider.baseURL,
            dependenciesResolver: dependenciesResolver
        )
        self.view?.setCardName(cardBoardingStepTracker.stepTracker.currentAlias)
        self.view?.setCardViewModel(viewModel)
    }
}

extension CardBoardingSummaryPresenter: CardBoardingSummaryPresenterProtocol {
    func didSelectMyCards() {
        self.coordinator.didSelectGoToMyCards(card: configuration.selectedCard)
    }
    
    func didSelectGlobalPosition() {
        self.coordinator.didSelectGoToGlobalPosition()
    }
    
    func didSelectImprove() {
        let opinator = RegularOpinatorInfoEntity(path: "appnew-general")
        self.coordinatorDelegate.handleOpinator(opinator)
    }
}

extension CardBoardingSummaryPresenter: AutomaticScreenTrackable {
    var trackerPage: CardBoardingSummaryPage {
        return CardBoardingSummaryPage()
    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
