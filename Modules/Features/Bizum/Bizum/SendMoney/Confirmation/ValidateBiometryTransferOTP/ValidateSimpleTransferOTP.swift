import CoreFoundationLib
import Operative

final class ValidateSimpleTransferOTP: ValidateTransferState {
    var tokenPush: GetLocalPushTokenUseCaseOkOutput?
    private var dependenciesResolver: DependenciesResolver
    private var operativeData: BizumSendMoneyOperativeData
    private var container: OperativeContainerProtocol
    private var otpCode: String

    init(dependenciesResolver: DependenciesResolver,
         operativeData: BizumSendMoneyOperativeData,
         container: OperativeContainerProtocol,
         otpCode: String) {
        self.dependenciesResolver = dependenciesResolver
        self.operativeData = operativeData
        self.container = container
        self.otpCode = otpCode
    }

    var getBizumSendMoneyOTPUseCase: BizumMoneyTransferOTPUseCase {
        self.dependenciesResolver.resolve(for: BizumMoneyTransferOTPUseCase.self)
    }

    func execute(_ handler: @escaping (Bool, String?) -> Void) {
        self.performBizumSendMoneyOTPUseCase(handler)
    }
}

private extension ValidateSimpleTransferOTP {
    func performBizumSendMoneyOTPUseCase(_ completion: @escaping (Bool, String?) -> Void) {
        guard let document = operativeData.document,
              let bizumValidateMoneyTransferEntity = operativeData.bizumValidateMoneyTransferEntity,
              let contact = operativeData.bizumContactEntity?.first,
              let amount = operativeData.bizumSendMoney?.amount,
              let concept = operativeData.bizumSendMoney?.concept
        else {
            return
        }
        let otpValidation: OTPValidationEntity = container.get()
        let input = BizumMoneyTransferOTPInputUseCase(
            checkPayment: operativeData.bizumCheckPaymentEntity,
            otpValidation: otpValidation,
            document: document,
            otpCode: otpCode,
            validateMoneyTransfer: bizumValidateMoneyTransferEntity,
            dateTime: Date(),
            concept: concept,
            amount: amount,
            receiverUserId: contact.phone,
            account: operativeData.accountEntity,
            tokenPush: self.tokenPush?.toStringTokenPush
        )
        Scenario(useCase: self.getBizumSendMoneyOTPUseCase, input: input)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] _ in
                guard let self = self else { return }
                self.sendMultimedia()
                completion(true, nil)
            }
            .onError { error in
                switch error {
                case .error(error: let otpError):
                    completion(false, otpError?.getErrorDesc() ?? "")
                default:
                    completion(false, localized("otp_error_unsuccessful"))
                }
            }
    }

    func sendMultimedia() {
        guard let multimediaData = self.operativeData.multimediaData, multimediaData.hasSomeValue(),
              let contacts = self.operativeData.bizumContactEntity,
              let container = self.container.operative as? BizumSendMoneyOperative else { return }
        let phones: [String] = contacts.map({ $0.phone })
        container.performSendMultimedia(phones.first)
    }
}
