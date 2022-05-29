//
//  CardActionFactory.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/30/19.
//

import Foundation
import CoreFoundationLib

public enum CreditCardActionSection: String, CaseIterable {
    case financing
    case otherOperatives
    case queries
    case contract
    case security
}

public enum PrepaidCardActionSection: String, CaseIterable {
    case otherOperatives
    case queries
    case contract
    case security
}

public enum DebitCardActionSection: String, CaseIterable {
    case otherOperatives
    case queries
    case contract
    case security
}

final class CardActionFactory: CardActionFactoryProtocol {
    private let dependenciesResolver: DependenciesResolver
    var isOTPExcepted: Bool = false
    var isPb: Bool = false
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    func getOtherOperativesCardActions(for card: CardEntity,
                                       offers: [PullOfferLocation: OfferEntity],
                                       cardActions: (CardAction, CardAction),
                                       isOTPExcepted: Bool) -> [CardActionViewModel] {
        let viewModel = CardViewModel(card,
                                      applePayState: .notSupported,
                                      isMapEnable: isMapEnable(),
                                      isEnableCashWithDrawal: isEnableCashWithDrawal(),
                                      dependenciesResolver: self.dependenciesResolver,
                                      maskedPAN: false)
        self.isOTPExcepted = isOTPExcepted
        let array = self.getCardHomeActions(for: viewModel, offers: offers, cardActions: cardActions, onlyFourActions: false)
        return Array(array.dropFirst(4))
    }
    
    func getCardHomeActions(for viewModel: CardViewModel, offers: [PullOfferLocation: OfferEntity], cardActions: (CardAction, CardAction), onlyFourActions: Bool = true, scaDate: Date? = nil) -> [CardActionViewModel] {
        var offersLocation = offers
        let cardHomeActionModifier = self.dependenciesResolver.resolve(firstTypeOf: CardHomeActionModifier.self)
        if let cardHomeModifier = dependenciesResolver.resolve(forOptionalType: CardHomeModifierProtocol.self) {
            offersLocation = cardHomeModifier.loadOffers(dependenciesResolver: dependenciesResolver)
        }
        if viewModel.isCreditCard {
            let arrayCreditCardActions = creditCardActions(cardActions, offers: offersLocation, viewModel: viewModel, scaDate: scaDate)
            let actionList = cardHomeActionModifier.getCreditCardHomeActions()
            return self.getCardTypeHomeActions(arrayCreditCardActions, actionList: actionList, entity: viewModel.entity, cardActions: cardActions, offers: offersLocation)
        } else if viewModel.isDebitCard {
            let arrayDebitCardsActions = debitCardActions(cardActions, offers: offersLocation, viewModel: viewModel)
            let actionList = cardHomeActionModifier.getDebitCardHomeActions()
            return self.getCardTypeHomeActions(arrayDebitCardsActions, actionList: actionList, entity: viewModel.entity, cardActions: cardActions, offers: offersLocation)
        } else if viewModel.isPrepaidCard {
            let arrayPrepaidCardsActions = prepaidCardActions(cardActions, offers: offersLocation, viewModel: viewModel)
            let actionList = cardHomeActionModifier.getPrepaidCardHomeActions()
            return self.getCardTypeHomeActions(arrayPrepaidCardsActions, actionList: actionList, entity: viewModel.entity, cardActions: cardActions, offers: offersLocation)
        } else {
            return []
        }
    }
}

// MARK: - Private
private extension CardActionFactory {

    private func creditCardActions(_ cardActions: (CardAction, CardAction), offers: [PullOfferLocation: OfferEntity], viewModel: CardViewModel, scaDate: Date?) -> [CardActionViewModel] {
        let builder = CardActionsBuilder(card: viewModel.entity, cardActions: cardActions)
        builder.addActivate(conditionedBy: isInactive)
        if !viewModel.entity.isInactive && isOnOffEnableForRetailUsers() && isOnOffEnableForPBUsers() && !viewModel.entity.isContractCancelled {
            builder.addOn(conditionedBy: isReadyForOn)
            builder.addOff(conditionedBy: isReadyForOff)
        }
        builder.addDirectMoney(conditionedBy: allowsDirectMoney, isFirstDays: isFirstDaysOfMonth(date: scaDate))
        builder.addPinQuery(isDisabled: viewModel.entity.isPINAndCVVDisabled)
        builder.addPayLater(conditionedBy: allowsPayLater)
        builder.addModifyLimits(conditionedBy: isEnableLimits)
        builder.addSolidary(conditionedBy: { _ in self.isThereCandidateOffer(for: CardsPullOffers.solidarity, offers: offers) }, offers: offers.filter { $0.key.stringTag == CardsPullOffers.solidarity })
        builder.addDetail()
        builder.addBlock(conditionedBy: allowsBlock)
        builder.addCES(conditionedBy: allowsCES)
        builder.addCvvQuery(isDisabled: viewModel.entity.isPINAndCVVDisabled)
        builder.addPayOff(conditionedBy: allowsPayOff)
        builder.addMobileTopUp()
        builder.addApplePay(state: viewModel.applePayState, condition: isApplePayEnable)
        builder.addPurchaseCard(conditionedBy: { _ in self.allowPurchaseCard(offers: offers) }, offers: offers.filter { $0.key.stringTag == CardsPullOffers.buyCard })
        builder.addSuscription(conditionedBy: { _ in self.isThereCandidateOffer(for: CardsPullOffers.suscriptionCardsHome, offers: offers) }, offers: offers.filter { $0.key.stringTag == CardsPullOffers.suscriptionCardsHome })
        builder.addPdfExtract(conditionedBy: allowsPdfExtract)
        builder.addHistoricPdfExtract(conditionedBy: allowsHistoricPdfExtract)
        builder.addFractionablePurchases(conditionedBy: enabledEasyPayCardOptions)
        builder.addSubscriptions(conditionedBy: enabledM4M)
        builder.addConfigureCard()
        builder.addChangePaymentMode(conditionedBy: allowsChangePaymentMode)
        builder.addFinancingBills(conditionedBy: allowsFinancingBills, offers: offers.filter { $0.key.stringTag == CardsPullOffers.financialBills })
        var actions = builder.build()
        guard !isMapEnable(), actions.count > 4 else {
            return actions
        }
        viewModel.setCardActionViewModel(actions.remove(at: 4))
        return actions
    }
     
    private func debitCardActions(_ cardActions: (CardAction, CardAction), offers: [PullOfferLocation: OfferEntity], viewModel: CardViewModel) -> [CardActionViewModel] {
        let builder = CardActionsBuilder(card: viewModel.entity, cardActions: cardActions)
        builder.addActivate(conditionedBy: isInactive)
        if !viewModel.entity.isInactive && isOnOffEnableForRetailUsers() && isOnOffEnableForPBUsers() && !viewModel.entity.isContractCancelled {
            builder.addOn(conditionedBy: isReadyForOn)
            builder.addOff(conditionedBy: isReadyForOff)
        }
        builder.addPinQuery(isDisabled: viewModel.entity.isPINAndCVVDisabled)
        builder.addModifyLimits(conditionedBy: isEnableLimits)
        builder.addSolidary(conditionedBy: { _ in self.isThereCandidateOffer(for: CardsPullOffers.solidarity, offers: offers) }, offers: offers.filter { $0.key.stringTag == CardsPullOffers.solidarity })
        builder.addMobileTopUp()
        builder.addDetail()
        builder.addPurchaseCard(conditionedBy: { _ in self.allowPurchaseCard(offers: offers) }, offers: offers.filter { $0.key.stringTag == CardsPullOffers.buyCard })
        builder.addBlock(conditionedBy: allowsBlock)
        builder.addCES(conditionedBy: allowsCES)
        builder.addCvvQuery(isDisabled: viewModel.entity.isPINAndCVVDisabled)
        builder.addApplePay(state: viewModel.applePayState, condition: isApplePayEnable)
        builder.addSuscription(conditionedBy: { _ in self.isThereCandidateOffer(for: CardsPullOffers.suscriptionCardsHome, offers: offers) }, offers: offers.filter { $0.key.stringTag == CardsPullOffers.suscriptionCardsHome })
        builder.addSubscriptions(conditionedBy: enabledM4M)
        builder.addConfigureCard()
        var actions = builder.build()
        guard !isMapEnable(), actions.count > 4 else {
            return actions
        }
        viewModel.setCardActionViewModel(actions.remove(at: 4))
        return actions
    }
    
    private func prepaidCardActions(_ cardActions: (CardAction, CardAction), offers: [PullOfferLocation: OfferEntity], viewModel: CardViewModel) -> [CardActionViewModel] {
        let builder = CardActionsBuilder(card: viewModel.entity, cardActions: cardActions)
        builder.addActivate(conditionedBy: isInactiveOrDisabled)
        if let modifier = dependenciesResolver.resolve(forOptionalType: CardHomeModifierProtocol.self), modifier.addPrepaidCardOffAction() {
            builder.addOn(conditionedBy: isReadyForOn)
            builder.addOff(conditionedBy: isReadyForOff)
        }
        builder.addChargeDischarge(conditionedBy: isActive)
        builder.addPinQuery(isDisabled: viewModel.entity.isPINAndCVVDisabled)
        builder.addBlock(conditionedBy: allowsBlock)
        builder.addDetail()
        builder.addPurchaseCard(conditionedBy: { _ in self.allowPurchaseCard(offers: offers) }, offers: offers.filter { $0.key.stringTag == CardsPullOffers.buyCard })
        builder.addCvvQuery(isDisabled: viewModel.entity.isPINAndCVVDisabled)
        builder.addSuscription(conditionedBy: { _ in self.isThereCandidateOffer(for: CardsPullOffers.suscriptionCardsHome, offers: offers) }, offers: offers.filter { $0.key.stringTag == CardsPullOffers.suscriptionCardsHome })
        return builder.build()
    }
    
    private func isApplePayEnable() -> Bool {
        return self.isAppConfigEnabled(node: CardConstants.isInAppEnrollmentEnabled)
    }
    
    private func isMapEnable() -> Bool {
        return self.isAppConfigEnabled(node: CardConstants.isEnableCardsHomeLocationMap)
    }
    
    private func isOnOffEnableForRetailUsers() -> Bool {
        if !self.isPb {
            return self.isAppConfigEnabled(node: CardConstants.isOnOffEnableForRetailUsers)
        } else {
            return true
        }
    }
    
    private func isOnOffEnableForPBUsers() -> Bool {
        if self.isPb {
            return self.isAppConfigEnabled(node: CardConstants.isOnOffEnableForPBUsers)
        } else {
            return true
        }
    }
    private func isEnableCashWithDrawal() -> Bool {
        return self.isAppConfigEnabled(node: CardConstants.isEnableCashWithDrawal)
    }
    private func isEnableCesEnrollment() -> Bool {
        return self.isAppConfigEnabled(node: CardConstants.isEnableCesEnrollment)
    }
    private func isEnableLimitsChangeCards() -> Bool {
        return self.isAppConfigEnabled(node: CardConstants.isEnableLimitsChangeCards)
    }
    
    private func isInactiveOrDisabled(card: CardEntity) -> Bool {
        guard let cardHomeModifier = dependenciesResolver.resolve(forOptionalType: CardHomeModifierProtocol.self),
              card.cardType == .prepaid else {
            return card.isDisabled || card.isInactive
        }
        return cardHomeModifier.isInactivePrepaid(card: card)
    }
    
    private func isFirstDaysOfMonth(date: Date?) -> Bool {
        let cardHomeActionModifier = self.dependenciesResolver.resolve(firstTypeOf: CardHomeActionModifier.self)
        return cardHomeActionModifier.checkIsFirstDays(date)
    }
    
    private func isInactive(card: CardEntity) -> Bool {
        return card.isInactive
    }
    
    private func isActive(card: CardEntity) -> Bool {
        return !card.isInactive
    }
    
    private func isCardContractHolder(card: CardEntity) -> Bool {
        return card.isCardContractHolder
    }
    
    private func isEnableLimits(card: CardEntity) -> Bool {
        return card.isCardContractHolder && isEnableLimitsChangeCards()
    }
    
    private func isActiveAndNotDisabled(card: CardEntity) -> Bool {
        return !card.isInactive && !card.isDisabled
    }

    private func isReadyForOff(card: CardEntity) -> Bool {
        return card.isReadyForOff
    }

    private func isReadyForOn(card: CardEntity) -> Bool {
        return card.isReadyForOn
    }
    
    private func allowsDirectMoney(card: CardEntity) -> Bool {
        return card.allowsDirectMoney && isAppConfigEnabled(node: "enableDirectMoney")
    }
    
    private func allowsPayLater(card: CardEntity) -> Bool {
        guard let currentBalance = card.currentBalance.value else { return false }
        return card.isContractActive && card.isCardContractHolder && isAppConfigEnabled(node: "enablePayLater") && abs(currentBalance) > 0
    }
    
    private func allowsPayOff(card: CardEntity) -> Bool {
        guard let currentBalance = card.currentBalance.value else { return false }
        return card.isContractActive && card.isCardContractHolder && abs(currentBalance) > 0
    }
    
    private func allowsBlock(card: CardEntity) -> Bool {
        return !card.isContractBlocked
    }
    
    private func allowsWithdrawMoney(card: CardEntity) -> Bool {
        return card.isDebitCard && card.isContractActive && !card.isTemporallyOff
    }
    
    private func allowsPdfExtract(card: CardEntity) -> Bool {
        let enableNextSettlementCreditCard = isAppConfigEnabled(node: "enableNextSettlementCreditCard")
        return !enableNextSettlementCreditCard && card.isCardContractHolder && card.isOwnerSuperSpeed
    }
    
    private func allowsHistoricPdfExtract(card: CardEntity) -> Bool {
        let enableNextSettlementCreditCard = isAppConfigEnabled(node: "enableNextSettlementCreditCard")
        return enableNextSettlementCreditCard
    }
    
    private func enabledEasyPayCardOptions(card: CardEntity) -> Bool {
        let enabledEasyPayCardOptions = isAppConfigEnabled(node: "enabledEasyPayCardOptions")
        return enabledEasyPayCardOptions
    }
    
    private func enabledM4M(card: CardEntity) -> Bool {
        let enabledM4M = isAppConfigEnabled(node: "enabledM4M")
        return enabledM4M && card.isVisible
    }
    
    private func allowsChangePaymentMode(card: CardEntity) -> Bool {
        return card.isCardContractHolder
    }
    
    private func isAppConfigEnabled(node: String) -> Bool {
        return self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self).getBool(node) ?? false
    }
    
    private func isThereCandidateOffer(for location: String, offers: [PullOfferLocation: OfferEntity]) -> Bool {
        return offers.contains(location: location)
    }
    
    private func allowsCES(card: CardEntity) -> Bool {
        return card.isContractActive && !card.isPrepaidCard && !self.isOTPExcepted && self.isEnableCesEnrollment()
    }
    
    private func allowPurchaseCard(offers: [PullOfferLocation: OfferEntity]) -> Bool {
        let isOfferCandidate = self.isThereCandidateOffer(for: CardsPullOffers.buyCard, offers: offers)
        let isSanflixEnabled = isAppConfigEnabled(node: "enableApplyBySanflix")
        return (isOfferCandidate && isSanflixEnabled) || !isSanflixEnabled
    }
    
    private func allowsFinancingBills(card: CardEntity, offers: [PullOfferLocation: OfferEntity]) -> Bool {
        return card.isCreditCard && card.isCardContractHolder && card.isVisible && self.isThereCandidateOffer(for: CardsPullOffers.financialBills, offers: offers)
    }
}

private extension CardActionFactory {
    func getCardTypeHomeActions(_ arrayHomeActions: [CardActionViewModel], actionList: [OldCardActionType], entity: CardEntity, cardActions: (CardAction, CardAction), offers: [PullOfferLocation: OfferEntity]) -> [CardActionViewModel] {
        var arrayDirectAccessActions: [CardActionViewModel] = []
        for actionType in actionList {
            if let element = arrayHomeActions.first(where: { $0.actionType == actionType }) {
                arrayDirectAccessActions.append(element)
            } else if case .custome(let values) = actionType {
                let candidateOffer = self.isThereCandidateOffer(for: values.location ?? "", offers: offers)
                if let cardHomeModifier = dependenciesResolver.resolve(forOptionalType: CardHomeModifierProtocol.self),
                   let action = cardHomeModifier.validatePullOffersCandidates(
                    values: values,
                    offers: offers,
                    entity: entity,
                    actionType: actionType,
                    action: cardActions.0,
                    candidateOffer: candidateOffer) {
                    arrayDirectAccessActions.append(action)
                }
            }
        }
        let cardHomeActionModifier = self.dependenciesResolver.resolve(firstTypeOf: CardHomeActionModifier.self)
        if cardHomeActionModifier.rearrangeApplePayAction() {
            return self.rearrangeApplePayButton(arrayDirectAccessActions: arrayDirectAccessActions)
        }
        return arrayDirectAccessActions
    }
    
    func rearrangeApplePayButton(arrayDirectAccessActions: [CardActionViewModel]) -> [CardActionViewModel] {
        guard let index = (arrayDirectAccessActions.firstIndex { $0.actionType == .applePay }) else {
            return arrayDirectAccessActions
        }
        var rearrangeActions = arrayDirectAccessActions
        let position = rearrangeActions.count > 3 ? 3 : rearrangeActions.count - 1
        let element = rearrangeActions.remove(at: index)
        rearrangeActions.insert(element, at: position)
        return rearrangeActions
    }
}
