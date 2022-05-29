//
//  GetCardTransactionDetailActionsUseCase.swift
//  Pods
//
//  Created by Hernán Villamil on 22/4/22.
//

import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetCardTransactionDetailActionsUseCase {
    func fetchCardTransactionDetailActions(item: CardTransactionViewItemRepresentable) -> AnyPublisher<[CardActions], Never>
}

struct DefaultGetCardTransactionDetailActionsUseCase {
    private let offerIntepreter: PullOffersInterpreter
    
    init(dependencies: CardTransactionDetailExternalDependenciesResolver) {
        self.offerIntepreter = dependencies.resolve()
    }
}

extension DefaultGetCardTransactionDetailActionsUseCase: GetCardTransactionDetailActionsUseCase {
    func fetchCardTransactionDetailActions(item: CardTransactionViewItemRepresentable) -> AnyPublisher<[CardActions], Never> {
        let actions = getActions(item: item)
        return Just(actions)
            .eraseToAnyPublisher()
    }
}

private extension DefaultGetCardTransactionDetailActionsUseCase {
    func getActions(item: CardTransactionViewItemRepresentable) -> [CardActions] {
        if item.card.isPrepaidCard {
            return getPrepaidCardActions(item: item)
        } else {
            return getOtherCardActions(item: item)
        }
    }
    
    func getPrepaidCardActions(item: CardTransactionViewItemRepresentable) -> [CardActions] {
        let builder = CardTransactionActionBuilder(card: item.card, action: nil)
        let subject = builder.stateSubject
        if item.configuration?.isSplitExpensesEnabled ?? false {
            let splitableitem = SplitableCardTransaction(card: item.card,
                                                         transaction: item.transaction)
            let input = AddDivideInput(splitableItem: splitableitem,
                                       customType: getDivideCustomViewType(),
                                       isDisabled: isActionDisabled(item.card))
            builder.stateSubject.send(.addDivideCustom(input))
        }
        subject.send(.addPrepaid(isActionDisabled(item.card)))
        subject.send(.addShare(isActionDisabled(item.card)))
        return builder.build()
    }
    
    func getOtherCardActions(item: CardTransactionViewItemRepresentable) -> [CardActions] {
        let builder = CardTransactionActionBuilder(card: item.card, action: nil)
        let subject = builder.stateSubject
        if isInactive(item.card) {
            subject.send(.addEnable)
        }
        if isDisabled(item.card) {
            subject.send(.addOn)
        }
        if !isDisabled(item.card) {
            subject.send(.addOff)
        }
        subject.send(.addShare(isActionDisabled(item.card)))
        subject.send(.addPDFDetail)
        return builder.build()
    }
}

private extension DefaultGetCardTransactionDetailActionsUseCase {
    func isInactive(_ card: CardRepresentable) -> Bool {
        card.isContractInactive || card.inactive == true
    }
    
    func isDisabled(_ card: CardRepresentable) -> Bool {
        card.isContractBlocked || card.isTemporallyOff == true
    }
    
    func isActionDisabled(_ card: CardRepresentable) -> Bool {
        isInactive(card) || isDisabled(card)
    }
    
    func getDivideCustomViewType() -> ActionButtonFillViewType {
        let actionViewType: ActionButtonFillViewType = .defaultWithBackground(
            DefaultActionButtonWithBackgroundViewModel(
                title: localized("transaction_buttonOption_expensesDivide"),
                imageKey: "icnBizumWhite",
                renderingMode: .alwaysOriginal,
                titleAccessibilityIdentifier: "transaction_buttonOption_expensesDivide",
                imageAccessibilityIdentifier: "",
                backgroundKey: "imgOperativeBgBizum",
                accessibilityButtonValue: "voiceover_optionSendMoneyMobile"))
        return actionViewType
    }
    
    func getFraudOffer() -> OfferEntity? {
        guard let offer = offerIntepreter.getValidOffer(offerId: "REPORTAR_FRAUDE") else {
            return nil
        }
        return OfferEntity(offer)
    }
}
