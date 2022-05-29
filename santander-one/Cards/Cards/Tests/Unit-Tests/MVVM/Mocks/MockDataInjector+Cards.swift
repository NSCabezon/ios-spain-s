//
//  MockDataInjector+Cards.swift
//  Pods
//
//  Created by Hernán Villamil on 23/4/22.
//

import Foundation
import CoreTestData

extension MockDataInjector {
    func injectMockCardData() {
        register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
        )
        register(
            for: \.gpData.getCardsInfoMock,
            filename: "posGlobalCardsList"
        )
        register(
            for: \.cardsData.getChangePayment,
            filename: "getChangePayment"
        )
        register(
            for: \.cardsData.getCardDetail,
            filename: "getCardDetail"
        )
        register(
            for: \.cardsData.getCardData,
            filename: "posGlobalCardsList"
        )
        register(
            for: \.cardsData.getCardSettlementMovements,
            filename: "getSettlementMovements"
        )
        register(
            for: \.cardsData.getCardMovementLocationListDTO,
            filename: "getCardMovementLocationListMock"
        )
        register(
            for: \.cardsData.getCardTransactionsList,
            filename: "getCardTransactions"
        )
        register(
            for: \.cardsData.getCardTransactionFeesEasyPay,
            filename: "getCardTransactionFeesEasyPay"
        )
        register(
            for: \.cardsData.getTransactionsEasyPayContract,
            filename: "getTransactionsEasyPayContract"
        )
        register(
            for: \.cardsData.getTransactionDetailEasyPay,
            filename: "getTransactionDetailEasyPay"
        )
        register(
            for: \.cardsData.getTransactionDetail,
            filename: "getTransactionDetail"
        )
        register(
            for: \.cardsData.getFeesInfo,
            filename: "getFeesInfo"
        )
    }
}
