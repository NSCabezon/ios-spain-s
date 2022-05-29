//
//  EasyPayDataEntity.swift
//  Models
//
//  Created by Tania Castellano Brasero on 06/05/2020.
//

import Foundation

public class EasyPayOperativeDataEntity {
    public let cardDetail: CardDetailEntity
    public let cardTransactionDetail: CardTransactionDetailEntity
    public let easyPayContractTransaction: EasyPayContractTransactionEntity
    public let easyPay: EasyPayEntity
    public let feeData: FeeDataEntity
    public var easyPayAmortization: EasyPayAmortizationEntity?
    
    public init(cardDetail: CardDetailEntity,
                cardTransactionDetail: CardTransactionDetailEntity,
                easyPayContractTransaction: EasyPayContractTransactionEntity,
                easyPay: EasyPayEntity,
                feeData: FeeDataEntity) {
        self.cardDetail = cardDetail
        self.cardTransactionDetail = cardTransactionDetail
        self.easyPayContractTransaction = easyPayContractTransaction
        self.easyPay = easyPay
        self.feeData = feeData
    }
}
