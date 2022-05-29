//
//  ActivateCardSummaryPresenter.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 13/10/2020.
//

import Foundation
import CoreFoundationLib
import Operative
import SANLegacyLibrary
import UI

protocol ActivateCardSummaryPresenterProtocol: OperativeStepPresenterProtocol {
    var view: ActivateCardSummaryViewProtocol? { get set }
    func viewDidLoad()
    func didSelectClose()
    func didSelectContinue()
    func didSelectedOffer(_ viewModel: OfferTipViewModel?)
    func setContinueButtonText() -> String
    func isBottomLabelVisible() -> Bool
}

extension ActivateCardSummaryPresenterProtocol {
    var shouldShowProgressBar: Bool {
        false
    }
}

final class ActivateCardSummaryPresenter {
    private let cardBoardingModifier: CardBoardingModifierProtocol?
    weak var view: ActivateCardSummaryViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var number: Int = 0
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var operativeData: CardBoardingActivationOperativeData {
        guard let container = self.container else { fatalError() }
        return container.get()
    }
    var tips: [OfferTipViewModel] = []
    var useCaseHandler: UseCaseHandler {
        self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.cardBoardingModifier = dependenciesResolver.resolve(forOptionalType: CardBoardingModifierProtocol.self)
    }
    
    private var cardTextColorEntity: [CardTextColorEntity] {
        self.dependenciesResolver.resolve(for: [CardTextColorEntity].self)
    }
    
    private var baseURLProvider: BaseURLProvider {
          return dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    private var getPullOffersCandidatesUseCase: GetPullOffersUseCase {
        self.dependenciesResolver.resolve()
    }
    
    private var coordinatorDelegate: CardsHomeModuleCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: CardsHomeModuleCoordinatorDelegate.self)
    }

    var activedCardUseCase: ActivatedCardUseCase {
        return self.dependenciesResolver.resolve(for: ActivatedCardUseCase.self)
    }
}

private extension ActivateCardSummaryPresenter {
    
    func loadActivateCardSummary(completion: @escaping () -> Void) {
        UseCaseWrapper(
            with: activedCardUseCase.setRequestValues(requestValues: GetActivatedCardUseCaseInput(card: operativeData.selectedCard)),
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

extension ActivateCardSummaryPresenter: ActivateCardSummaryPresenterProtocol {
    func didSelectedOffer(_ viewModel: OfferTipViewModel?) {
        guard let offer = viewModel?.representable.offerRepresentable else { return }
        self.coordinatorDelegate.didSelectOffer(offer: offer)
    }
    
    func viewDidLoad() {
        self.trackScreen()
        let viewModel = PlasticCardViewModel(entity: operativeData.selectedCard,
                                             textColorEntity: self.cardTextColorEntity,
                                             baseUrl: self.baseURLProvider.baseURL ?? "",
                                             dependenciesResolver: dependenciesResolver)
        self.view?.showCard(viewModel: viewModel)
        self.loadActivateCardSummary {
            self.view?.showOffers(offers: self.tips)
        }
    }
    
    func didSelectContinue() {
        self.trackEvent(.activate, parameters: [:])
        if self.isCardBoardingAvailable() {
            self.container?.save(CardBoardingActivationOperative.FinishingOption.goToCardBoarding)
        } else if shouldPresentReceivePin() {
            self.container?.save(CardBoardingActivationOperative.FinishingOption.goToReceivePin)
        } else {
            self.container?.save(CardBoardingActivationOperative.FinishingOption.goToCardHome)
        }
        self.container?.stepFinished(presenter: self)
    }

    func didSelectClose() {
        self.container?.save(CardBoardingActivationOperative.FinishingOption.goToCardHome)
        self.trackEvent(.exit, parameters: [:])
        self.container?.close()
    }
    
    func setContinueButtonText() -> String {
        if !returnLiteralReceivePin().isEmpty {
            return returnLiteralReceivePin()
        } else if isCardBoardingAvailable() {
            return "cardBoarding_button_customizeCard"
        } else {
            return "cardBoarding_button_goCards"
        }
    }
    
    func isBottomLabelVisible() -> Bool {
        return self.isCardBoardingTextVisible()
    }
}

extension ActivateCardSummaryPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: ActivateCardSummaryPage {
        return ActivateCardSummaryPage()
    }
}

private extension ActivateCardSummaryPresenter {
    func isCardBoardingAvailable() -> Bool {
        return cardBoardingModifier?.isCardBoardingAvailable() ?? false
    }
    
    func isCardBoardingTextVisible() -> Bool {
        return cardBoardingModifier?.isCardBoardingTextVisible() ?? true
    }

    func shouldPresentReceivePin() -> Bool {
        return cardBoardingModifier?.shouldPresentReceivePin() ?? false
    }
    
    func returnLiteralReceivePin() -> String {
        return cardBoardingModifier?.returnPresentLiteralReceivePin() ?? ""
    }
}
