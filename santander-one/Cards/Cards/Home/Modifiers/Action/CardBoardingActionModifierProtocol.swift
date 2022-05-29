//
//  CardBoardingActionModifier.swift
//  Cards
//
//  Created by Mario Rosales Maillo on 30/12/21.
//

import CoreFoundationLib

public protocol CardBoardingActionModifierProtocol: AnyObject {
    func didSelectAction(_ action: OldCardActionType, _ entity: CardEntity)
}
