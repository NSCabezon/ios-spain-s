//
//  CardHomeActionModifier.swift
//  Cards
//
//  Created by David Gálvez Alonso on 22/02/2021.
//

import CoreFoundationLib
import Foundation

open class CardHomeActionModifier {
    public var next: CardHomeActionModifier?
    public let dependenciesResolver: DependenciesResolver
    public var completion: ((DependenciesResolver) -> Void)?
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    @discardableResult
    public func add(_ modifier: CardHomeActionModifier) -> Self {
        if let next = self.next {
            next.add(modifier)
            next.setCompletion(self.completion)
        } else {
            self.next = modifier
            self.next?.setCompletion(self.completion)
        }
        return self
    }
    
    public func setCompletion(_ completion: ((DependenciesResolver) -> Void)?) {
        self.completion = completion
    }
    
    @discardableResult
    public func reset() -> Self {
        self.next = nil
        return self
    }
    
    func addExtraModifier() {
        self.next?.addExtraModifier()
    }
    
    open func getDebitCardHomeActions() -> [OldCardActionType] {
        return self.next?.getDebitCardHomeActions() ?? []
    }
    
    open func getCreditCardHomeActions() -> [OldCardActionType] {
        return self.next?.getCreditCardHomeActions() ?? []
    }
    
    open func getPrepaidCardHomeActions() -> [OldCardActionType] {
        return self.next?.getPrepaidCardHomeActions() ?? []
    }
    
    open func didSelectAction(_ action: OldCardActionType, _ entity: CardEntity) {
        self.next?.didSelectAction(action, entity)
    }

    open func loadOffers() -> [PullOfferLocation: OfferEntity] {
        return self.next?.loadOffers() ?? [:]
    }

    open func rearrangeApplePayAction() -> Bool {
        return self.next?.rearrangeApplePayAction() ?? true
    }
    
    open func checkIsFirstDays(_ date: Date?) -> Bool {
        return self.next?.checkIsFirstDays(date) ?? false
    }
}
