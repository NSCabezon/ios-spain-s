//
//  SpainCardBoardingModifier.swift
//  Santander
//
//  Created by Laura González Salvador on 29/4/22.
//

import Foundation
import Cards
import CoreFoundationLib
import Operative

final class SpainCardBoardingModifier: CardBoardingModifierProtocol {
    func isCardBoardingAvailable() -> Bool {
        return true
    }
    
    func isSignatureNeeded() -> Bool {
        return false
    }
    
    func alwaysActivateCardOnCardboarding() -> Bool {
        return true
    }
    
    func isCardBoardingTextVisible() -> Bool {
        return true
    }
    
    func returnPresentLiteralReceivePin() -> String? {
        return nil
    }
    
    func shouldPresentReceivePin() -> Bool {
        return false
    }
    
    func goToReceivePinWebViewWithCard(
        card: CardEntity,
        resolver: DependenciesResolver,
        coordinator: OperativeContainerCoordinatorProtocol,
        onError: @escaping () -> Void
    ) {}
}
