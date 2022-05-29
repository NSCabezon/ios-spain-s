//
//  CardBoardingWelcomePresenter.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 12/11/2020.
//

import Foundation
import CoreFoundationLib
import Operative
import SANLegacyLibrary
import UI
import CoreDomain

protocol CardBoardingWelcomePresenterProtocol: AnyObject {
    var view: CardBoardingWelcomeViewProtocol? { get set }
    func viewDidLoad()
    func didSelectClose()
    func didSelectContinue()
    func didSelectOffer(_ offer: OfferRepresentable)
}

final class CardBoardingWelcomePresenter {
    weak var view: CardBoardingWelcomeViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var tips: [OfferTipViewModel] = []
    var useCaseHandler: UseCaseHandler {
        self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var cardTextColorEntity: [CardTextColorEntity] {
        return self.dependenciesResolver.resolve(for: [CardTextColorEntity].self)
    }
    
    private var baseURLProvider: BaseURLProvider {
          return dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    private var configuration: CardboardingConfiguration {
         return dependenciesResolver.resolve(for: CardboardingConfiguration.self)
     }

    private var welcomeCardUseCase: CardBoardingWelcomeUseCase {
        return self.dependenciesResolver.resolve(for: CardBoardingWelcomeUseCase.self)
    }
    
    private var coordinator: CardBoardingWelcomeCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: CardBoardingWelcomeCoordinatorProtocol.self)
    }
}

private extension CardBoardingWelcomePresenter {
    
    func loadCardBoardingWelcome(completion: @escaping () -> Void) {
        UseCaseWrapper(
            with: welcomeCardUseCase.setRequestValues(requestValues: GetCardBoardingWelcomeUseCaseInput(card: configuration.selectedCard)),
            useCaseHandler: useCaseHandler,
            onSuccess: { [weak self] result in
                self?.tips = (result.tips?.map {
                    return OfferTipViewModel($0, baseUrl: self?.baseURLProvider.baseURL)
                    } ?? [])
                completion()
            }, onError: { _ in
                completion()
        })
    }
}

extension CardBoardingWelcomePresenter: CardBoardingWelcomePresenterProtocol {
    func didSelectOffer(_ offer: OfferRepresentable) {
        self.coordinator.didSelectOffer(offer)
    }
    
    func viewDidLoad() {
        self.trackScreen()
        let viewModel = PlasticCardViewModel(entity: (configuration.selectedCard),
                                             textColorEntity: self.cardTextColorEntity,
                                             baseUrl: self.baseURLProvider.baseURL ?? "",
                                             dependenciesResolver: dependenciesResolver)
        self.view?.showCard(viewModel: viewModel)
        self.loadCardBoardingWelcome {
            self.view?.showOffers(self.tips)
        }
    }
    
    func didSelectContinue() {
        self.trackEvent(.configure, parameters: [:])
        self.coordinator.didSelectContinue(card: configuration.selectedCard)
    }

    func didSelectClose() {
        self.trackEvent(.exit, parameters: [:])
        self.coordinator.didSelectClose()
    }
}

extension CardBoardingWelcomePresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: CardBoardingWelcomePage {
        return CardBoardingWelcomePage()
    }
}
