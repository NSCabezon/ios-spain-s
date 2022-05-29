//
//  BizumAcceptMoneyRequestOperativeData.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 01/12/2020.
//

import Foundation
import CoreFoundationLib

final class BizumAcceptMoneyRequestOperativeData {
    let bizumCheckPaymentEntity: BizumCheckPaymentEntity
    var accountEntity: AccountEntity?
    var bizumContacts: [BizumContactEntity]?
    var document: BizumDocumentEntity?
    var bizumSendMoney: BizumSendMoney?
    var multimediaData: BizumMultimediaData?
    var operation: BizumHistoricOperationEntity?
    var simpleMultipleType: BizumSimpleMultipleType?
    var validateMoneyTransferOTPEntity: BizumValidateMoneyTransferOTPEntity?
    
    init(bizumCheckPaymentEntity: BizumCheckPaymentEntity) {
        self.bizumCheckPaymentEntity = bizumCheckPaymentEntity
    }
}
