import CoreFoundationLib

final class BizumDonationOperativeData: BizumMoneyOperativeData {
    var bizumOperativeType: BizumOperativeType
    var typeUserInSimpleSend: BizumRegisterUserType = .register
    var accounts: [AccountEntity] = []
    var bizumContactEntity: [BizumContactEntity]?
    var simpleMultipleType: BizumSimpleMultipleType?
    let bizumCheckPaymentEntity: BizumCheckPaymentEntity
    var accountEntity: AccountEntity?
    var document: BizumDocumentEntity?
    var validateMoneyTransferOTPEntity: BizumValidateMoneyTransferOTPEntity?
    var bizumValidateMoneyTransferEntity: BizumValidateMoneyTransferEntity?
    var bizumSendMoney: BizumSendMoney?
    var multimediaData: BizumMultimediaData?
    var organization: BizumNGOProtocol?
    var operationDate: Date

    init(bizumCheckPaymentEntity: BizumCheckPaymentEntity) {
        self.bizumCheckPaymentEntity = bizumCheckPaymentEntity
        self.bizumOperativeType = .donation
        self.operationDate = Date()
    }
}
