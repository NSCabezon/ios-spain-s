//
//  MockCardTransactionViewItemRepresentable.swift
//  Pods
//
//  Created by Hernán Villamil on 23/4/22.
//

import Foundation
import CoreDomain
struct MockCardTransactionViewItem {
    let card: CardRepresentable
    let transaction: CardTransactionRepresentable
    let showAmountBackground: Bool
    var cardDetail: CardDetailRepresentable?
    var transactionDetail: CardTransactionDetailRepresentable?
    var configuration: CardTransactionDetailConfigRepresentable?
    var contract: EasyPayContractTransactionRepresentable?
    var feeData: FeeDataRepresentable?
    var easyPay: EasyPayRepresentable?
    var isFractioned: Bool = false
    var minEasyPayAmount: Double?
    var viewConfiguration: [CardTransactionDetailViewConfigurationRepresentable]?
    var error: String?
    var offerRepresentable: OfferRepresentable?
    var shouldPresentFractionatedButton: Bool?
    
    init(card: CardRepresentable,
         transaction: CardTransactionRepresentable,
         showAmountBackground: Bool) {
        self.card = card
        self.transaction = transaction
        self.showAmountBackground = showAmountBackground
    }
}

extension MockCardTransactionViewItem: CardTransactionViewItemRepresentable {
    var viewConfigurationRepresentable: [CardTransactionDetailViewConfigurationRepresentable] {
        get {
            viewConfiguration ?? []
        }
        set(newValue) {
            viewConfiguration = newValue
        }
    }
}
