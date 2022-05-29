//
//  CardActionsBuilder.swift
//  Cards
//
//  Created by Jose Carlos Estela Anguita on 16/12/2019.
//

import CoreFoundationLib

public typealias CardAction = ((OldCardActionType, CardEntity) -> Void)?

final class CardActionsBuilder {
    
    // MARK: - Private
    private let card: CardEntity
    private var actions: [CardActionViewModel] = []
    private let cardActions: (delegateAction: CardAction, applePay: CardAction)
    
    private func isDisabled() -> Bool {
        return card.isDisabled || card.isInactive
    }

    // MARK: - Public
    
    init(card: CardEntity, cardActions: (delegateAction: CardAction, applePay: CardAction)) {
        self.cardActions = cardActions
        self.card = card
    }
    
    func build() -> [CardActionViewModel] {
        return self.actions
    }
    
    // Apagar tarjeta
    func addOff(conditionedBy condition: @escaping (CardEntity) -> Bool) {
        guard condition(card) else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .offCard,
                action: self.cardActions.delegateAction)
        )
    }
    
    // Encender tarjeta
    func addOn(conditionedBy condition: @escaping (CardEntity) -> Bool) {
        guard condition(card) else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .onCard,
                action: self.cardActions.delegateAction)
        )
    }
    
    // Efectivo al instante
    func addDirectMoney(conditionedBy condition: @escaping (CardEntity) -> Bool, isFirstDays: Bool) {
        guard condition(card) else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .instantCash,
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled(),
                isFirstDays: isFirstDays)
        )
    }
    
    // Consultar PIN
    func addPinQuery(isDisabled: Bool) {
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .pin,
                action: self.cardActions.delegateAction,
                isDisabled: isDisabled)
        )
    }
    
    // Consultar extracto
    func addPdfExtract(conditionedBy condition: @escaping (CardEntity) -> Bool) {
        guard condition(card) else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .pdfExtract,
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled())
        )
    }
    
    // Historico de extractos
    func addHistoricPdfExtract(conditionedBy condition: @escaping (CardEntity) -> Bool) {
        guard condition(card) else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .historicPdfExtract,
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled())
        )
    }
    
    // Acceso a compras praccionadas
    func addFractionablePurchases(conditionedBy condition: @escaping (CardEntity) -> Bool) {
        guard condition(card) else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .fractionablePurchases,
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled())
        )
    }
    
    // Acceso a subscripciones
    func addSubscriptions(conditionedBy condition: @escaping (CardEntity) -> Bool) {
        guard condition(card) else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .subscriptions,
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled())
        )
    }
    
    // Sacar dinero con móvil
    func addWithdrawMoney(conditionedBy condition: @escaping (CardEntity) -> Bool) {
        guard condition(card) else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .withdrawMoneyWithCode,
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled())
        )
    }
    
    // Modificar limites
    func addModifyLimits(conditionedBy condition: @escaping (CardEntity) -> Bool) {
        guard condition(card) else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card, type: .modifyLimits,
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled())
        )
    }
    
    // Activar tarjeta
    func addActivate(conditionedBy condition: @escaping (CardEntity) -> Bool) {
        guard condition(card) else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .enable,
                action: self.cardActions.delegateAction)
        )
    }
    
    // Carga y descarga de tarjeta prepago
    func addChargeDischarge(conditionedBy condition: @escaping (CardEntity) -> Bool) {
        guard condition(card) else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .chargeDischarge,
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled())
        )
    }
    
    // Consultar CVV
    func addCvvQuery(isDisabled: Bool) {
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .cvv,
                action: self.cardActions.delegateAction,
                isDisabled: isDisabled)
        )
    }
    
    // Bloquear tarjeta
    func addBlock(conditionedBy condition: @escaping (CardEntity) -> Bool) {
        guard condition(card) else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .block,
                action: self.cardActions.delegateAction,
                isDisabled: false)
        )
    }
    
    // Detalle de tarjeta
    func addDetail() {
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .detail,
                action: self.cardActions.delegateAction,
                isDisabled: false)
        )
    }
    
    // Retrasar recibo con Pago Luego
    func addPayLater(conditionedBy condition: @escaping (CardEntity) -> Bool) {
        guard condition(card) else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .delayPayment,
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled())
        )
    }
    
    // Ingreso en tarjeta
    func addPayOff(conditionedBy condition: @escaping (CardEntity) -> Bool) {
        guard condition(card) else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .payOff,
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled())
        )
    }
    
    // Recarga de móvil
    func addMobileTopUp() {
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .mobileTopUp,
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled())
        )
    }
    
    // Alta en comercio electrónico seguro
    func addCES(conditionedBy condition: @escaping (CardEntity) -> Bool) {
        guard condition(card) else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .ces,
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled())
        )
    }
    
    // Redondeo solidario (Oferta)
    func addSolidary(conditionedBy condition: @escaping (CardEntity) -> Bool, offers: [PullOfferLocation: OfferEntity]) {
        guard condition(card), let offer = offers.first else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .solidarityRounding(offer.value),
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled())
        )
    }
    
    // Cambio forma de pago
    func addChangePaymentMode(conditionedBy condition: @escaping (CardEntity) -> Bool) {
        guard condition(card) else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .changePaymentMethod,
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled())
        )
    }
    
    // Contratación de tarjetas (Oferta)
    func addPurchaseCard(conditionedBy condition: @escaping (CardEntity) -> Bool, offers: [PullOfferLocation: OfferEntity]) {
        guard condition(card) else { return }
        let offer = offers.first
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .hireCard(offer?.key),
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled())
        )
    }
    
    func addApplePay(state: CardApplePayState, condition: () -> Bool) {
        guard condition() else { return }
        let isDisabled = (state == .notSupported || state == .inactiveAndDisabled)
        let isActive = .active == state
        let title: String = isActive ? localized("cardsOption_button_addedApple") : localized("cardsOption_button_addApple")
        let image: String = {
            guard !isDisabled else { return "icnApayDisactive" }
            return isActive ? "icnApayCheck" : "icnApay"
        }()
        
        let actionViewModel = CardActionViewModel(
            entity: card,
            type: .applePay,
            viewType: .defaultButton(DefaultActionButtonViewModel(
                title: title,
                imageKey: image,
                renderingMode: .alwaysOriginal,
                titleAccessibilityIdentifier: "cardsHomeBtnApplePay_title",
                imageAccessibilityIdentifier: image
                )),
            action: self.cardActions.applePay,
            isDisabled: isDisabled,
            isUserInteractionEnable: .inactive == state
        )
        self.actions.insert(actionViewModel, at: 3)
    }
    
    // Pedir un duplicado
    func duplicateCard(conditionedBy condition: @escaping (CardEntity) -> Bool) {
        guard condition(card) else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .duplicateCard,
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled())
        )
    }
    
    func addConfigureCard() {
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .configure,
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled())
        )
    }
    
    func addSuscription(conditionedBy condition: @escaping (CardEntity) -> Bool, offers: [PullOfferLocation: OfferEntity]) {
        guard condition(card), let offer = offers.first else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .suscription(offer.value),
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled())
        )
    }
    
    func addFinancingBills(conditionedBy condition: @escaping (CardEntity, [PullOfferLocation: OfferEntity]) -> Bool, offers: [PullOfferLocation: OfferEntity]) {
        guard condition(card, offers), let offer = offers.first else { return }
        self.actions.append(
            CardActionViewModel(
                entity: card,
                type: .financingBills(offer.value),
                action: self.cardActions.delegateAction,
                isDisabled: self.isDisabled())
        )
    }
}
