//
//  EasyPayOperativeData.swift
//  Cards
//
//  Created by alvola on 01/12/2020.
//
import CoreFoundationLib
import Operative

final class EasyPayOperativeData {
    let isSelectorVisible: Bool
    var list: [CardTransactionWithCardEntity]?
    var productSelected: CardTransactionWithCardEntity?
    var cardDetail: CardDetailEntity?
    var cardTransactionDetail: CardTransactionDetailEntity?
    var easyPayContractTransaction: EasyPayContractTransactionEntity?
    var easyPay: EasyPayEntity?
    var feeData: FeeDataEntity?
    var easyPayAmortization: EasyPayAmortizationEntity?
    var easyPayCurrentFeeData: EasyPayCurrentFeeDataEntity?
    
    init(product: CardTransactionWithCardEntity?) {
        self.productSelected = product
        self.isSelectorVisible = product == nil
    }
    
    func updatePre(cardTransactions: [CardTransactionWithCardEntity]) {
        self.list = cardTransactions
    }
    
    func update(cardDetail: CardDetailEntity,
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

extension EasyPayOperativeData: OperativeParameterLegacy {}
