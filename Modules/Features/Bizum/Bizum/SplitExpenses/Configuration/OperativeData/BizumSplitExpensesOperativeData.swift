//
//  BizumSplitExpensesOperativeData.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 11/01/2021.
//

import Foundation
import CoreFoundationLib

final class BizumSplitExpensesOperativeData: BizumMoneyOperativeData {
    let bizumCheckPaymentEntity: BizumCheckPaymentEntity
    let operation: SplitableExpenseProtocol
    var accountEntity: AccountEntity?
    var bizumContactEntity: [BizumContactEntity]? {
        didSet {
            self.calculateAmounts()
        }
    }
    var accounts: [AccountEntity] = []
    var document: BizumDocumentEntity?
    var bizumSendMoney: BizumSendMoney?
    var multimediaData: BizumMultimediaData?
    var simpleMultipleType: BizumSimpleMultipleType?
    var bizumOperativeType: BizumOperativeType
    var typeUserInSimpleSend: BizumRegisterUserType
    var concept: String?
    var bizumValidateMoneyRequestEntity: BizumValidateMoneyRequestEntity?
    var bizumValidateMoneyRequestMultiEntity: BizumValidateMoneyRequestMultiEntity?
    var ownAmount: AmountEntity?
    let operationDate: Date
    
    init(bizumCheckPaymentEntity: BizumCheckPaymentEntity, operation: SplitableExpenseProtocol, bizumSendMoney: BizumSendMoney) {
        self.bizumCheckPaymentEntity = bizumCheckPaymentEntity
        self.typeUserInSimpleSend = .register
        self.bizumOperativeType = .requestMoney
        self.operation = operation
        self.bizumSendMoney = bizumSendMoney
        self.operationDate = Date()
    }
    
    func calculateAmounts() {
        guard
            let contacts = self.bizumContactEntity?.count,
            let operationAmount = self.operation.amount.value.map(abs)
        else {
            return
        }
        let rounding = NSDecimalNumberHandler(roundingMode: .down,
                                              scale: 2,
                                              raiseOnExactness: false,
                                              raiseOnOverflow: false,
                                              raiseOnUnderflow: false,
                                              raiseOnDivideByZero: false)
        let contactAmountRequested = (operationAmount as NSDecimalNumber)
            .dividing(by: NSDecimalNumber(value: contacts + 1))
            .rounding(accordingToBehavior: rounding)
            .decimalValue
        let totalAmount = (contactAmountRequested as NSDecimalNumber)
            .multiplying(by: NSDecimalNumber(value: contacts))
            .decimalValue
        let ownAmount = operationAmount - totalAmount
        self.bizumSendMoney?.setAmount(contactAmountRequested)
        self.bizumSendMoney?.setTotalAmount(totalAmount)
        self.ownAmount = AmountEntity(value: ownAmount)
    }
}
