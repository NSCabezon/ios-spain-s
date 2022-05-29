import CoreFoundationLib

final class BizumCancelOperativeData {
    let bizumCheckPaymentEntity: BizumCheckPaymentEntity
    let operationEntity: BizumHistoricOperationEntity
    var accountEntity: AccountEntity?
    var document: BizumDocumentEntity?
    
    init(bizumCheckPaymentEntity: BizumCheckPaymentEntity, operationEntity: BizumHistoricOperationEntity) {
        self.bizumCheckPaymentEntity = bizumCheckPaymentEntity
        self.operationEntity = operationEntity
    }
}
