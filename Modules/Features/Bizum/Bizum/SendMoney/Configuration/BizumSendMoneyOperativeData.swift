import CoreFoundationLib

enum BizumRegisterUserType {
    case noRegister
    case register
}

final class BizumSendMoneyOperativeData: BizumMoneyOperativeData {
    let bizumOperativeType: BizumOperativeType
    let bizumCheckPaymentEntity: BizumCheckPaymentEntity
    var typeUserInSimpleSend: BizumRegisterUserType = .register
    var accounts: [AccountEntity] = []
    var accountEntity: AccountEntity?
    var bizumContactEntity: [BizumContactEntity]?
    var document: BizumDocumentEntity?
    var validateMoneyTransferOTPEntity: BizumValidateMoneyTransferOTPEntity?
    var bizumValidateMoneyTransferEntity: BizumValidateMoneyTransferEntity?
    var bizumValidateMoneyTransferMultiEntity: BizumValidateMoneyTransferMultiEntity?
    var bizumSendMoney: BizumSendMoney?
    var multimediaData: BizumMultimediaData?
    var simpleMultipleType: BizumSimpleMultipleType?
    let operationDate: Date
    var isBiometricValidationEnable: Bool = false
    var isBiometricEnable: Bool = false

    init(bizumCheckPaymentEntity: BizumCheckPaymentEntity) {
        self.bizumCheckPaymentEntity = bizumCheckPaymentEntity
        self.bizumOperativeType = .sendMoney
        self.operationDate = Date()
    }
}
