//
//  CardHomeActionModifierDelegate.swift
//  Cards
//
//  Created by David Gálvez Alonso on 09/03/2021.
//

import CoreFoundationLib

public protocol CardHomeModifierProtocol {
    func isPANAlwaysSharable() -> Bool
    func isPANMasked() -> Bool
    func isCardHighlitghtedButtonsHidden() -> Bool
    func didSelectCardPendingTransactions()
    func showCardPAN(card: CardEntity)
    func isCardPANMasked(cardId: String) -> Bool
    func getCardPAN(cardId: String) -> String?
    func formatPAN(card: CardEntity) -> String?
    func validatePullOffersCandidates(values: CustomCardActionValues,
                                      offers: [PullOfferLocation: OfferEntity],
                                      entity: CardEntity,
                                      actionType: OldCardActionType,
                                      action: ((OldCardActionType, CardEntity) -> Void)?,
                                      candidateOffer: Bool ) -> CardActionViewModel?
    func loadOffers(dependenciesResolver: DependenciesResolver) -> [PullOfferLocation: OfferEntity]
    func isInactivePrepaid(card: CardEntity) -> Bool
    func showActivateView() -> Bool
    func getSelectedCardFromConfiguration() -> CardEntity?
    func hideCardsHomeImageDetailsConditions() -> Bool
    func addPrepaidCardOffAction() -> Bool
    func hideMoreOptionsButton() -> Bool
}

public protocol CardsTransactionListSortedProtocol {
    var sortCondition: (CardTransactionsGroupViewModel, CardTransactionsGroupViewModel) -> Bool { get }
}
