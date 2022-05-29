//
//  ApplePayEnrollmentPresenter.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/7/20.
//

import Foundation
import CoreFoundationLib

protocol ApplePayEnrollmentPresenterProtocol {
    var view: ApplePayEnrollmentViewProtocol? { get set }
    func viewDidLoad()
    func didSelectBack()
    func didSelectNext()
    func didSelectEnrollInApplePay()
    func didSelectApplePayOffer(_ viewModel: ApplePayOfferViewModel)
    func didSelectHowToPay(_ viewModel: ApplePayOfferViewModel)
}

final class ApplePayEnrollmentPresenter {
    private let dependenciesResolver: DependenciesResolver
    weak var view: ApplePayEnrollmentViewProtocol?
    private var offers: [PullOfferLocation: OfferEntity] = [:]
    
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
    private var pullOfferUseCase: GetPullOffersUseCase {
        return self.dependenciesResolver.resolve(for: GetPullOffersUseCase.self)
    }
    private var usecaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func viewDidLoad() {
        self.loadPullOffers()
        self.showApplePayEnrollment()
        self.setPlatictCard()
    }
}

private extension ApplePayEnrollmentPresenter {
    func setPlatictCard() {
        let card = configuration.selectedCard
        let viewModel = PlasticCardViewModel(
            entity: card,
            textColorEntity: cardColorsArray,
            baseUrl: urlProvider.baseURL,
            dependenciesResolver: dependenciesResolver
        )
        self.view?.setViewModel(viewModel)
    }
    
    func loadPullOffers() {
        let locations = PullOffersLocationsFactoryEntity().cardBoardingApplePay
        let imput = GetPullOffersUseCaseInput(locations: locations)
        UseCaseWrapper(
            with: self.pullOfferUseCase.setRequestValues(requestValues: imput),
            useCaseHandler: self.usecaseHandler,
            onSuccess: { [weak self] response in
                self?.offers = response.pullOfferCandidates
                self?.setOfferViewModel()
            }, onError: { [weak self] _ in
                self?.view?.setOfferViewModel(nil)
            })
    }
    
    func setOfferViewModel() {
        let welcomeOffer = self.offers.location(key: CardBoardingConstants.welcomeOfferLocation)?.offer
        let confirmationOffer = self.offers.location(key: CardBoardingConstants.confirmationOfferLocation)?.offer
        let viewModel = ApplePayOfferViewModel(welcomeOffer: welcomeOffer, confirmationOffer: confirmationOffer)
        self.view?.setOfferViewModel(viewModel)
    }
    
    func showApplePayEnrollment() {
        guard case .active = self.cardBoardingStepTracker.stepTracker.applePayState else {
            self.view?.showAddToApplePay()
            return
        }
        self.view?.showApplaPaySuccess()
    }
}

extension ApplePayEnrollmentPresenter: ApplePayEnrollmentPresenterProtocol {
    func didSelectBack() {
        self.coordinator.didSelectGoBackwards()
    }
    
    func didSelectNext() {
        self.coordinator.didSelectGoFoward()
    }
    
    func didSelectEnrollInApplePay() {
        let card = configuration.selectedCard
        self.coordinatorDelegate.didSelectAddToApplePay(card: card, delegate: self)
    }
    
    func didSelectApplePayOffer(_ viewModel: ApplePayOfferViewModel) {
        guard let offer = viewModel.welcomeOffer else { return }
        self.coordinatorDelegate.didSelectOffer(offer: offer)
    }
    
    func didSelectHowToPay(_ viewModel: ApplePayOfferViewModel) {
        guard let offer = viewModel.confirmationOffer else { return }
        self.coordinatorDelegate.didSelectOffer(offer: offer)
    }
}

extension ApplePayEnrollmentPresenter: ApplePayEnrollmentDelegate {
    func applePayEnrollmentDidFinishSuccessfully() {
        self.cardBoardingStepTracker.stepTracker.updateApplePayState(applePayState: .active)
        self.view?.showApplaPaySuccess()
    }
    
    func applePayEnrollmentDidFinishWithError(_ error: ApplePayError) {}
}

extension ApplePayEnrollmentPresenter: AutomaticScreenTrackable {
    var trackerPage: CardBoardingApplePayPage {
        return CardBoardingApplePayPage()
    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
