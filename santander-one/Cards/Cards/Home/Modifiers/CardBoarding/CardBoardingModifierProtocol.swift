//
//  CardBoardingModifierPRotocol.swift
//  Cards
//
//  Created by Gabriel Tondin on 06/05/2021.
//

import Foundation
import CoreFoundationLib
import Operative

public protocol CardBoardingModifierProtocol {
    func isCardBoardingAvailable() -> Bool
    func isSignatureNeeded() -> Bool
    func alwaysActivateCardOnCardboarding() -> Bool
    func isCardBoardingTextVisible() -> Bool
    /// Controls wether to show or not to user the Receive PIN WebView after
    /// the Boarding Operative has ended.
    ///
    /// - Returns: Default value is `false`.
    func shouldPresentReceivePin() -> Bool
    /// Goes to Receive PIN WebView, default implementation does nothing.
    ///
    /// - Parameters:
    ///   - card: Card to be received PIN with.
    ///   - resolver: Dependencies Resolver to resolve the WebViewConfig getter.
    ///   - coordinator: Coordinator to return to source view after `X` is tappen.
    ///   - onError: Returns an error if it's not possible to get WebView configuration correctly.
    func goToReceivePinWebViewWithCard(
        card: CardEntity,
        resolver: DependenciesResolver,
        coordinator: OperativeContainerCoordinatorProtocol,
        onError: @escaping () -> Void
    )
    func returnPresentLiteralReceivePin() -> String?
}

public extension CardBoardingModifierProtocol {
    func shouldPresentReceivePin() -> Bool { false }
    func returnPresentLiteralReceivePin() -> String? { return nil }
    func goToReceivePinWebViewWithCard(
        card: CardEntity,
        resolver: DependenciesResolver,
        coordinator: OperativeContainerCoordinatorProtocol,
        onError: @escaping () -> Void
    ) { }
}
