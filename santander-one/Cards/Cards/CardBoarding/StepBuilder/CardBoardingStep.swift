//
//  CardBoardingStep.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/14/20.
//

import Foundation

protocol CardBoardingStepView: AnyObject {
    var isFirstStep: Bool { get set }
}

protocol CardBoardingStep {
    var view: CardBoardingStepView? { get }
    func showTopBarItems() -> Bool
    func setAsFirstStep()
}

extension CardBoardingStep {
    func showTopBarItems() -> Bool {
        return true
    }
}
