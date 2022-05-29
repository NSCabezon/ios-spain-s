//
//  EasyPayOperativeDataRepresentable.swift
//  CoreDomain
//
//  Created by Hernán Villamil on 24/4/22.
//

import Foundation

public protocol EasyPayOperativeDataRepresentable {
    var cardDetail: CardDetailRepresentable? { get set }
    var cardTransactionDetail: CardTransactionDetailRepresentable? { get set }
    var easyPayContractTransaction: EasyPayContractTransactionRepresentable? { get set }
    var easyPay: EasyPayRepresentable? { get set }
    var feeData: FeeDataRepresentable? { get set }
    var easyPayAmortizationRepresentable: FeesInfoRepresentable? { get set }
}
