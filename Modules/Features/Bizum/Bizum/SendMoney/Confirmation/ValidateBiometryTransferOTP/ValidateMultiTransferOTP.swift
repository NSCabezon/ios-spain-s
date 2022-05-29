import CoreFoundationLib
import Operative

final class ValidateMultiTransferOTP: ValidateTransferState {
    var tokenPush: GetLocalPushTokenUseCaseOkOutput?
    private var dependenciesResolver: DependenciesResolver
    private var operativeData: BizumSendMoneyOperativeData?
    private var container: OperativeContainerProtocol?
    private var otpCode: String?

    var getBizumSendMoneyOTPMMultiUseCase: BizumMoneyTransferOTPMultiUseCase {
        return dependenciesResolver.resolve()
    }

    init(dependenciesResolver: DependenciesResolver,
         operativeData: BizumSendMoneyOperativeData,
         container: OperativeContainerProtocol,
         otpCode: String) {
        self.dependenciesResolver = dependenciesResolver
        self.operativeData = operativeData
        self.container = container
        self.otpCode = otpCode
    }

    func execute(_ handler: @escaping (Bool, String?) -> Void) {
        self.performBizumSendMoneyOTPMMultiUseCase(otpCode: self.otpCode, completion: handler)
    }
}
private extension ValidateMultiTransferOTP {
    func performBizumSendMoneyOTPMMultiUseCase(otpCode: String?, completion: @escaping (Bool, String?) -> Void) {
        guard let operativeData = self.operativeData,
              let container = self.container,
              let document = operativeData.document,
              let validateMoneyTransferEntity = operativeData.bizumValidateMoneyTransferMultiEntity,
              let amount = operativeData.bizumSendMoney?.amount,
              let concept = operativeData.bizumSendMoney?.concept
        else {
            return
        }
        let input = BizumMoneyTransferOTPMultiInputUseCase(
            checkPayment: operativeData.bizumCheckPaymentEntity,
            otpValidation: container.get(),
            document: document,
            otpCode: otpCode ?? "",
            validateMoneyTransferMulti: validateMoneyTransferEntity,
            dateTime: Date(),
            concept: concept,
            amount: amount,
            account: operativeData.accountEntity,
            tokenPush: self.tokenPush?.toStringTokenPush)
        Scenario(useCase: self.getBizumSendMoneyOTPMMultiUseCase, input: input)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { _ in
                self.sendMultimedia()
                completion(true, nil)
            }
            .onError { error in
                switch error {
                case .error(error: let moneyTransferError):
                    completion(false, moneyTransferError?.getErrorDesc() ?? localized("otp_error_unsuccessful"))
                default:
                    completion(false, localized("otp_error_unsuccessful"))
                }
            }
    }

    func sendMultimedia() {
        guard let operativeData = self.operativeData,
              let multimediaData = operativeData.multimediaData, multimediaData.hasSomeValue(),
              let contacts = operativeData.bizumContactEntity,
              let container = self.container?.operative as? BizumSendMoneyOperative else { return }
        let phones: [String] = contacts.map({ $0.phone })
        container.performSendMultimedia(phones)
    }
}
