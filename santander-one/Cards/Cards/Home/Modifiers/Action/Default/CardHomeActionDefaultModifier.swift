//
//  CardHomeActionDefaultModifier.swift
//  Cards
//
//  Created by David Gálvez Alonso on 22/02/2021.
//

import CoreFoundationLib
import Foundation

final class CardHomeActionDefaultModifier: CardHomeActionModifier {
        
    override func getDebitCardHomeActions() -> [OldCardActionType] {
        if let next = super.next {
            return next.getDebitCardHomeActions()
        } else {
            return [.applePay, .enable, .onCard, .offCard, .pin, .modifyLimits, .solidarityRounding(nil), .mobileTopUp, .detail, .hireCard(nil), .block, .ces, .cvv, .suscription(nil), .subscriptions, .configure]
        }
    }
    
    override func getCreditCardHomeActions() -> [OldCardActionType] {
        if let next = super.next {
            return next.getCreditCardHomeActions()
        } else {
            return [.applePay, .onCard, .offCard, .instantCash, .pin, .enable, .delayPayment, .modifyLimits, .solidarityRounding(nil), .detail, .block, .ces, .cvv, .payOff, .mobileTopUp, .hireCard(nil), .suscription(nil), .pdfExtract, .historicPdfExtract, .fractionablePurchases, .subscriptions, .configure, .financingBills(nil), .changePaymentMethod]
        }
    }
    
    override func getPrepaidCardHomeActions() -> [OldCardActionType] {
        if let next = super.next {
            return next.getPrepaidCardHomeActions()
        } else {
            return [.applePay, .chargeDischarge, .pin, .block, .detail, .hireCard(nil), .cvv, .enable, .suscription(nil)]
        }
    }
    
    override func addExtraModifier() {
        self.completion?(self.dependenciesResolver)
    }
    
    override func didSelectAction(_ action: OldCardActionType, _ entity: CardEntity) {
        if let next = super.next {
            next.didSelectAction(action, entity)
        } else {
            return self.didSelectCardAction(action, entity)
        }
    }
    
    override func checkIsFirstDays(_ date: Date?) -> Bool {
        if let next = super.next {
            return next.checkIsFirstDays(date)
        } else {
            guard let date = date else { return false }
            return date.isBeforeFifthDayInMonth()
        }
    }
}

private extension CardHomeActionDefaultModifier {
    func didSelectCardAction(_ action: OldCardActionType, _ entity: CardEntity) {
        self.dependenciesResolver.resolve(for: CardsHomeModuleCoordinatorDelegate.self)
            .didSelectAction(action, entity)
    }
}
