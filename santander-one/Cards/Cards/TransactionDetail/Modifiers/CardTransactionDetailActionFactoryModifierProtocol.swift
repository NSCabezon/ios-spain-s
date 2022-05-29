//
//  CardTransactionDetailActionFactoryModifierProtocol.swift
//  Cards
//
//  Created by Gabriel Tondin on 05/04/2021.
//

import CoreFoundationLib

public protocol CardTransactionDetailActionFactoryModifierProtocol: AnyObject {
    func addPDFDetail(transaction: CardTransactionEntity) -> Bool
    func customViewType() -> ActionButtonFillViewType
    func getCustomActions(for card: CardEntity, forTransaction transaction: CardTransactionEntity) -> [OldCardActionType]?
    func didSelectAction(_ action: OldCardActionType, forTransaction transaction: CardTransactionEntity, andCard card: CardEntity) -> Bool
}

public extension CardTransactionDetailActionFactoryModifierProtocol {
    func addPDFDetail(transaction: CardTransactionEntity) -> Bool {
        return false
    }

    func getCustomActions(for card: CardEntity, forTransaction transaction: CardTransactionEntity) -> [OldCardActionType]? {
        return nil
    }

    func didSelectAction(_ action: OldCardActionType, forTransaction transaction: CardTransactionEntity, andCard card: CardEntity) -> Bool {
        return false
    }
}
