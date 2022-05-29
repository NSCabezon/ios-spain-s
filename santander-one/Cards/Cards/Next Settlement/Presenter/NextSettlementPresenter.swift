//
//  NextSettlementPresenter.swift
//  Cards
//
//  Created by Laura González on 05/10/2020.
//

import Foundation
import CoreFoundationLib

protocol NextSettlementPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: NextSettlementViewProtocol? { get set }
    func viewDidLoad()
    func didSelectDismiss()
    func didMoreMovementsSelected()
    func didTapInOtherCard(_ index: Int)
    func didTapPickerCard(_ index: Int)
    func trackFaqEvent(_ question: String, url: URL?)
}

final class NextSettlementPresenter {
    weak var view: NextSettlementViewProtocol?
    let dependenciesResolver: DependenciesResolver
    
    private var nextSettlementViewModel: NextSettlementViewModel?
    
    var nextSettlementCoordinator: NextSettlementCoordinator {
        return dependenciesResolver.resolve(for: NextSettlementCoordinator.self)
    }
    
    var configuration: NextSettlementConfiguration {
        return self.dependenciesResolver.resolve(for: NextSettlementConfiguration.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension NextSettlementPresenter: NextSettlementPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        self.getMovements()
    }
    
    func didSelectDismiss() {
        self.nextSettlementCoordinator.dismiss()
    }

    func didTapInOtherCard(_ index: Int) {
        let selectedPan = index == 0 ? self.nextSettlementViewModel?.getOwnerPanOrOriginalPan : self.nextSettlementViewModel?.getFirstAssociatedPan
        self.nextSettlementViewModel?.setCurrentPanSelected(selectedPan ?? "")
        guard let nextSettlementViewModel = nextSettlementViewModel,
            let cardSelected = nextSettlementViewModel.getCurrentCardSelected(selectedPan ?? "")?.entity,
            let isEnabledPostponeReceipt = self.nextSettlementViewModel?.getEnabledPostponeReceipt(cardSelected)
            else { return }
        self.view?.reloadTicketViewModel(nextSettlementViewModel)
        self.buildCardActions(nextSettlementViewModel.getScaDate, isEnabledPostponeReceipt: isEnabledPostponeReceipt, card: cardSelected)
    }
    
    func didTapPickerCard(_ index: Int) {
        guard
            let ownerCards = nextSettlementViewModel?.ownerCards,
            let nextSettlementViewModel = nextSettlementViewModel,
            let cardSelected = nextSettlementViewModel.getCurrentCardSelected(ownerCards[index].pan)?.entity,
            let isEnabledPostponeReceipt = self.nextSettlementViewModel?.getEnabledPostponeReceipt(cardSelected)
            else { return }
        self.nextSettlementViewModel?.setCurrentPanSelected(ownerCards[index].pan)
        self.view?.reloadTicketViewModel(nextSettlementViewModel)
        self.buildCardActions(nextSettlementViewModel.getScaDate, isEnabledPostponeReceipt: isEnabledPostponeReceipt, card: cardSelected)
    }
    
    func didMoreMovementsSelected() {
        nextSettlementCoordinator.gotoNextSettlementMovements(configuration.card, nextSettlementViewModel: nextSettlementViewModel)
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        let eventId = url == nil ? "click_show_faq" : "click_link_faq"
        var dic: [String: String] = ["faq_question": question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        trackerManager.trackEvent(screenId: "credit_cards_upcoming_liquidations", eventId: eventId, extraParameters: dic)
    }
}

private extension NextSettlementPresenter {
    var baseURLProvider: BaseURLProvider {
        return dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    var cardSettlementMovementsUseCase: GetCardSettlementMovementsUseCase {
        return self.dependenciesResolver.resolve(for: GetCardSettlementMovementsUseCase.self)
    }
    
    var getCardPaymentMethodUseCase: GetCardPaymentMethodUseCase {
        return self.dependenciesResolver.resolve(for: GetCardPaymentMethodUseCase.self)
    }
    
    var homeCoordinatorDelegate: CardsHomeModuleCoordinatorDelegate? {
        return self.dependenciesResolver.resolve(for: CardsHomeModuleCoordinatorDelegate.self)
    }
    
    func isMapMultipleTransactionEnabled() -> Bool {
        guard
            self.configuration.cardSettlementDetailEntity.startDate != nil,
            self.configuration.cardSettlementDetailEntity.endDate != nil
        else {
            return configuration.isMultipleMapEnabled
        }
        return true
    }
    
    func isOwnerOfCard(_ card: CardEntity) -> Bool {
        return card.isOwnerSuperSpeed
    }
    
    func setCardActions(_ entity: CardEntity, scaDate: Date, isEnabledPostponeReceipt: Bool, action: ((NextSettlementActionType, CardEntity) -> Void)?) {
        var actions: [NextSettlementActionViewModel] = []
        actions.append(NextSettlementActionViewModel(type: .postponeReceipt,
                                                     entity: entity,
                                                     isDisabled: !isEnabledPostponeReceipt,
                                                     action: action,
                                                     isRemarkable: nextSettlementViewModel?.isReceiptRemarkable ?? false))
        actions.append(NextSettlementActionViewModel(type: .changePaymentMethod,
                                                     entity: entity,
                                                     isDisabled: !isOwnerOfCard(entity),
                                                     action: action))
        actions.append(NextSettlementActionViewModel(type: .historicExtractPDF,
                                                     entity: entity,
                                                     action: action))
        actions.append(NextSettlementActionViewModel(type: .shoppingMap,
                                                     entity: entity,
                                                     isDisabled: !isMapMultipleTransactionEnabled(),
                                                     action: action))
        self.view?.setActions(actions)
    }
    
    func didSelectAction(_ type: NextSettlementActionType, cardEntity: CardEntity) {
        switch type {
        case .postponeReceipt, .changePaymentMethod, .historicExtractPDF:
            self.homeCoordinatorDelegate?.didSelectSettlementAction(type, entity: cardEntity)
        case .shoppingMap:
            self.didSelectMapSettlement(cardEntity)
        }
    }
           
    func didSelectMapMultipleTransactions(_ selectedCard: CardEntity) {
        guard self.configuration.isMultipleMapEnabled else { return }
        self.nextSettlementCoordinator.goToMapView(selectedCard, type: CardMapTypeConfiguration.multiple)
    }
    
    func didSelectMapSettlement(_ selectedCard: CardEntity) {
        guard
            let startDate = self.configuration.cardSettlementDetailEntity.startDate,
            let endDate = self.configuration.cardSettlementDetailEntity.endDate
            else {
                self.didSelectMapMultipleTransactions(selectedCard)
                return
        }
        let configurationMapType = CardMapTypeConfiguration.date(startDate: startDate, endDate: endDate)
        self.nextSettlementCoordinator.goToMapView(selectedCard, type: configurationMapType)
    }
    
    func getMovements() {
        self.view?.setLoadingView()
        UseCaseWrapper(
            with: cardSettlementMovementsUseCase.setRequestValues(requestValues: GetCardSettlementMovementsUseCaseInput(cardEntity: configuration.card, cardSettlementDetailEntity: configuration.cardSettlementDetailEntity)),
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                guard let self = self else { return }
                self.setTicketViewModel(result)
        })
    }
    
    func buildCardActions(_ scaDate: Date, isEnabledPostponeReceipt: Bool, card: CardEntity) {
        self.setCardActions(card, scaDate: scaDate, isEnabledPostponeReceipt: isEnabledPostponeReceipt) { [weak self] action, entity in
            self?.didSelectAction(action, cardEntity: entity)
            guard
                let trackName = action.trackName,
                let actionType = CardSettlementDetailPage.ActionType(rawValue: trackName)
            else { return }
            self?.trackEvent(actionType, parameters: [:])
        }
    }
    
    func getCardEntities(_ userCards: [CardEntity], movementsWithPAN: [CardSettlementMovementWithPANEntity]) -> [NextSettlementMovementWithPANViewModel] {
        let movementsForPAN: [NextSettlementMovementWithPANViewModel] = userCards.compactMap { (card) in
            var movements: [CardSettlementMovementEntity]?
            for entity in movementsWithPAN where card.formattedPAN == entity.PAN {
                movements = entity.movements
            }
            return NextSettlementMovementWithPANViewModel(card, movementsEntity: movements)
        }
        return movementsForPAN
    }
    
    func setTicketViewModel(_ result: GetCardSettlementMovementsUseCaseOkOutput) {
        let movements = self.getCardEntities(result.userCards, movementsWithPAN: result.settlementMovements)
        self.getPaymentMethod(configuration.card, completion: { [weak self] (paymentMethod, paymentMethodDescription) in
            self?.view?.hideLoadingView { [weak self] in
                guard let self = self else { return }
                let ticketViewModel = NextSettlementViewModel(self.configuration,
                                                              cardDetail: result.cardDetail,
                                                              baseUrl: self.baseURLProvider.baseURL,
                                                              movements: movements,
                                                              paymentMethod: paymentMethod,
                                                              paymentMethodDescription: paymentMethodDescription,
                                                              isMultipleMapEnabled: self.isMapMultipleTransactionEnabled(),
                                                              ownerPan: result.ownerPan,
                                                              scaDate: result.scaDate,
                                                              enablePayLater: result.enablePayLater)
                self.view?.setTicketViewModel(ticketViewModel)
                self.nextSettlementViewModel = ticketViewModel
                self.buildCardActions(result.scaDate, isEnabledPostponeReceipt: self.nextSettlementViewModel?.isEnabledPostponeReceipt ?? false, card: self.configuration.card)
                self.showCreditCardFAQs(result.faqs)
            }
        })
    }
    
    func getPaymentMethod(_ entity: CardEntity, completion: @escaping (CardPaymentMethodTypeEntity?, String?) -> Void) {
        UseCaseWrapper(
            with: self.getCardPaymentMethodUseCase.setRequestValues(requestValues: GetCardPaymentMethodUseCaseInput(card: entity)),
            useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { result in
                guard let paymentMethodDescription = result.currentPaymentMethodMode else {
                    return completion(nil, nil)
                }
                completion(result.currentPaymentMethod, paymentMethodDescription)
            },
            onError: { _ in
                completion(nil, nil)
        })
    }
    
    func showCreditCardFAQs(_ creditCardFAQs: [FaqsEntity]?) {
        let baseURL = (self.baseURLProvider.baseURL ?? "").dropLast(1)
        self.view?.showCreditCardFAQs(creditCardFAQs, baseUrl: String(baseURL))
    }
}

extension NextSettlementPresenter: AutomaticScreenActionTrackable {
    var trackerPage: CardSettlementDetailPage {
        return CardSettlementDetailPage()
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
