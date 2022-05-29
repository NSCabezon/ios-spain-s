import CoreFoundationLib

final class BizumRefundMoneyOperativeData {
    
    let totalAmount: AmountEntity
    let operation: BizumHistoricOperationEntity
    let checkPayment: BizumCheckPaymentEntity
    let bizumContacts: [BizumContactEntity]
    var comment: String?
    var account: AccountEntity?
    var document: BizumDocumentEntity?
    
    init(totalAmount: AmountEntity, operation: BizumHistoricOperationEntity, checkPayment: BizumCheckPaymentEntity) {
        self.totalAmount = totalAmount
        self.operation = operation
        self.checkPayment = checkPayment
        self.bizumContacts = [
            BizumContactEntity(
                identifier: BizumUtils.getIdentifier(operation.emitterAlias, phone: operation.emitterId ?? ""),
                name: nil,
                phone: operation.emitterId ?? "",
                alias: operation.emitterAlias ?? ""
            )
        ]
    }
}
