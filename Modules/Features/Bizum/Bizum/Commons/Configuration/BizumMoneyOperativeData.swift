import CoreFoundationLib

enum BizumOperativeType {
    case sendMoney
    case requestMoney
    case donation
}

protocol BizumMoneyOperativeData {
    var bizumOperativeType: BizumOperativeType { get }
    var bizumCheckPaymentEntity: BizumCheckPaymentEntity { get }
    var typeUserInSimpleSend: BizumRegisterUserType { get set }
    var accountEntity: AccountEntity? { get set }
    var accounts: [AccountEntity] { get set }
    var bizumContactEntity: [BizumContactEntity]? { get set }
    var document: BizumDocumentEntity? { get set }
    var bizumSendMoney: BizumSendMoney? { get set }
    var multimediaData: BizumMultimediaData? { get set }
    var simpleMultipleType: BizumSimpleMultipleType? { get set }
}
