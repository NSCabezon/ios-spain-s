//
//  GetCardTransactionDetailViewConfiguration.swift
//  Pods
//
//  Created by Hernán Villamil on 21/4/22.
//

import Foundation
import CoreDomain
import OpenCombine
import CoreFoundationLib

public protocol GetCardTransactionDetailViewConfigurationUseCase {
    func fetchCardTransactionDetailViewConfiguration(transaction: CardTransactionRepresentable,
                                                     detail: CardTransactionDetailRepresentable?) -> AnyPublisher<[CardTransactionDetailViewConfigurationRepresentable], Never>
}

struct DefaultGetCardTransactionDetailViewConfigurationUseCase {

    init() {}
}

extension DefaultGetCardTransactionDetailViewConfigurationUseCase: GetCardTransactionDetailViewConfigurationUseCase {
    func fetchCardTransactionDetailViewConfiguration(transaction: CardTransactionRepresentable, detail: CardTransactionDetailRepresentable?) -> AnyPublisher<[CardTransactionDetailViewConfigurationRepresentable], Never> {
        return Just(getConfiguration(transaction: transaction,
                                     detail: detail))
            .eraseToAnyPublisher()
    }
}

private extension DefaultGetCardTransactionDetailViewConfigurationUseCase {
    func getConfiguration(transaction: CardTransactionRepresentable,
                          detail: CardTransactionDetailRepresentable?) -> [CardTransactionDetailViewConfigurationRepresentable] {
        let operationDate = getOperationDateView(transaction: transaction, detail: detail)
        let soldOut = getSoldOutView(detail: detail)
        let configRow1 = CardTransactionDetailViewConfiguration(left: operationDate, right: soldOut)
        let annotationDate = getAnnotationDateView(transaction: transaction)
        let retentionCharges = getRetentionChargesView(detail: detail)
        let configRow2 = CardTransactionDetailViewConfiguration(left: annotationDate, right: retentionCharges)
        return [configRow1, configRow2]
    }
    
    func getOperationDateView(transaction: CardTransactionRepresentable,
                              detail: CardTransactionDetailRepresentable?) -> CardTransactionDetailView {
        var view = CardTransactionDetailView(title: localized("transaction_label_operationDate"),
                                             value: nil)

        view.viewType = .operationDate
        return view
    }
    
    func getSoldOutView(detail: CardTransactionDetailRepresentable?) -> CardTransactionDetailView {
        var view = CardTransactionDetailView(title: getSoldOutDescrtiption(detail: detail),
                                  value: nil)
        view.viewType = .liquidation
        return view
    }
    
    func getAnnotationDateView(transaction: CardTransactionRepresentable) -> CardTransactionDetailView {
        var view = CardTransactionDetailView(title: localized("transaction_label_annotationDate"),
                                  value: nil)
        view.viewType = .annotationDate
        return view
    }
    
    func getRetentionChargesView(detail: CardTransactionDetailRepresentable?) -> CardTransactionDetailView {
        var view = CardTransactionDetailView(title: localized("transaction_label_fees"),
                                  value: getBankCharge(detail: detail) ?? "")
        view.viewType = .fees
        return view
    }
    
    func getSoldOutDescrtiption(detail: CardTransactionDetailRepresentable?) -> String {
        guard let transactionDetail = detail else { return localized("cardDetail_text_liquidated") }
        if transactionDetail.isSoldOut {
            return localized("cardDetail_text_liquidated")
        } else {
            return localized("cardDetail_text_notLiquidated")
        }
    }
    
    func getBankCharge(detail: CardTransactionDetailRepresentable?) -> String? {
        guard let charge = detail?.bankChargeRepresentable
        else { return "" }
        return AmountEntity(charge).getStringValue()
    }
}
