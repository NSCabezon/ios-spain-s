//
//  HistoricExtractOperativeData.swift
//  Cards
//
//  Created by Ignacio González Miró on 12/11/2020.
//

import CoreFoundationLib

final class HistoricExtractOperativeData {
    var card: CardEntity
    var cardSettlementDetailEntity: CardSettlementDetailEntity?
    var currentPaymentMethod: CardPaymentMethodTypeEntity?
    var currentPaymentMethodMode: String?
    var settlementMovements: [CardSettlementMovementEntity]?
    var cardDetail: CardDetailEntity?
    var scaDate: Date?
    var ownerPan: String? {
        guard let emptyMovements = cardSettlementDetailEntity?.emptyMovements, !emptyMovements else { return "" }
        return self.card.cardContract
    }
    var isMultipleMapEnabled: Bool = false
    
    init(_ card: CardEntity) {
        self.card = card
    }
}
