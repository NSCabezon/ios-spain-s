import CoreFoundationLib

final class BizumRequestMoneyOperativeData: BizumMoneyOperativeData {
    let bizumOperativeType: BizumOperativeType
    let bizumCheckPaymentEntity: BizumCheckPaymentEntity
    var typeUserInSimpleSend: BizumRegisterUserType = .register
    var accountEntity: AccountEntity?
    var accounts: [AccountEntity] = []
    var bizumContactEntity: [BizumContactEntity]?
    var document: BizumDocumentEntity?
    var bizumValidateMoneyRequestEntity: BizumValidateMoneyRequestEntity?
    var bizumValidateMoneyRequestMultiEntity: BizumValidateMoneyRequestMultiEntity?
    var bizumSendMoney: BizumSendMoney?
    var multimediaData: BizumMultimediaData?
    var simpleMultipleType: BizumSimpleMultipleType?
    let operationDate: Date

    init(bizumCheckPaymentEntity: BizumCheckPaymentEntity) {
        self.bizumCheckPaymentEntity = bizumCheckPaymentEntity
        self.bizumOperativeType = .requestMoney
        self.operationDate = Date()
    }
}
