//
//  CardTransactionConfiguration.swift
//  Pods
//
//  Created by Hernán Villamil on 11/4/22.
//

import Foundation
import CoreDomain
import CoreFoundationLib

final class CardTransactionItem {
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
    var shouldPresentFractionatedButton: Bool? = false
    
    init(card: CardRepresentable,
         transaction: CardTransactionRepresentable,
         showAmountBackground: Bool) {
        self.card = card
        self.transaction = transaction
        self.showAmountBackground = showAmountBackground
    }
}

extension CardTransactionItem: CardTransactionViewItemRepresentable {
    var viewConfigurationRepresentable: [CardTransactionDetailViewConfigurationRepresentable] {
        get {
            viewConfiguration ?? getConfiguration(transaction)
        }
        set(newValue) {
            viewConfiguration = newValue
        }
    }
}

private extension CardTransactionItem {
    func getConfiguration(_ transaction: CardTransactionRepresentable) -> [CardTransactionDetailViewConfigurationRepresentable] {
        let operationDate = getOperationDateView(transaction: transaction)
        let soldOut = getSoldOutView()
        let configRow1 = CardTransactionDetailViewConfiguration(left: operationDate, right: soldOut)
        let annotationDate = getAnnotationDateView(transaction: transaction)
        let retentionCharges = getRetentionChargesView()
        let configRow2 = CardTransactionDetailViewConfiguration(left: annotationDate, right: retentionCharges)
        return [configRow1, configRow2]
    }
    
    func getOperationDateView(transaction: CardTransactionRepresentable) -> CardTransactionDetailView {
        var view = CardTransactionDetailView(title: localized("transaction_label_operationDate"),
                                  value: nil)
        view.viewType = .operationDate
        return view
    }
    
    func getSoldOutView() -> CardTransactionDetailView {
        var view = CardTransactionDetailView(title: localized("cardDetail_text_notLiquidated"),
                                  value: "")
        view.viewType = .liquidation
        return view
    }
    
    func getAnnotationDateView(transaction: CardTransactionRepresentable) -> CardTransactionDetailView {
        var view = CardTransactionDetailView(title: localized("transaction_label_annotationDate"),
                                  value: nil)
        view.viewType = .annotationDate
        return view
    }
    
    func getRetentionChargesView() -> CardTransactionDetailView {
        var view = CardTransactionDetailView(title: localized("transaction_label_fees"),
                                  value: "")
        view.viewType = .fees
        return view
    }
}
