import Foundation
import CoreFoundationLib
import Operative

private enum ErrorTokenPush: Error {
    case emptyToken
}

final class ValidateBiometryTransferOTP {
    private var state: ValidateTransferState?
    private var dependenciesResolver: DependenciesResolver
    private var tokenPush: GetLocalPushTokenUseCaseOkOutput?
    var operativeData: BizumSendMoneyOperativeData
    var container: OperativeContainerProtocol

    init(dependenciesResolver: DependenciesResolver,
         operativeData: BizumSendMoneyOperativeData,
         container: OperativeContainerProtocol) {
        self.dependenciesResolver = dependenciesResolver
        self.operativeData = operativeData
        self.container = container
    }

    func execute(deviceToken: String, footprint: String, completion: @escaping (Bool, String?) -> Void) {
        self.getTokenPush { [weak self] result in
            guard let self = self else { return }
            self.state?.tokenPush = result
            self.performValidateMoneyTransferOTPUseCase(
                deviceToken: deviceToken,
                footprint: footprint,
                completion: completion
            )
        }
    }

    func update(state: ValidateTransferState) {
        self.state = state
    }
}

private extension ValidateBiometryTransferOTP {
    var getTokenPushUseCase: GetLocalPushTokenUseCase {
        self.dependenciesResolver.resolve(for: GetLocalPushTokenUseCase.self)
    }

    var getValidateMoneyTransferOTPUseCase: BizumValidateMoneyTransferOTPUseCase {
        self.dependenciesResolver.resolve(for: BizumValidateMoneyTransferOTPUseCase.self)
    }

    func getTokenPush(handler: @escaping (GetLocalPushTokenUseCaseOkOutput) -> Void) {
        Scenario(useCase: getTokenPushUseCase)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { response in
                handler(response)
            }
    }

    func performValidateMoneyTransferOTPUseCase(deviceToken: String, footprint: String, completion: @escaping (Bool, String?) -> Void) {
        guard let amount = operativeData.bizumSendMoney?.amount,
              let signatureToken: SignatureWithTokenEntity = container.get(),
              let signaturePositions = signatureToken.positions
        else {
            return
        }
        signatureToken.values = Array(repeating: "", count: signaturePositions.count )
        let input = BizumValidateMoneyTransferOTPInputUseCase(
            checkPayment: self.operativeData.bizumCheckPaymentEntity,
            signatureWithToken: container.get(),
            amount: amount,
            numberOfRecipients: operativeData.bizumContactEntity?.count ?? 0,
            account: operativeData.accountEntity,
            footPrint: footprint,
            deviceToken: deviceToken)
        Scenario(useCase: self.getValidateMoneyTransferOTPUseCase, input: input)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] response in
                guard let self = self else { return }
                let validateMoneyTransferOTPEntity = response.validateMoneyTransferOTPEntity
                self.operativeData.validateMoneyTransferOTPEntity = validateMoneyTransferOTPEntity
                self.container.save(self.operativeData)
                self.container.save(validateMoneyTransferOTPEntity.otp)
                self.state?.execute(completion)
            }
            .onError { error in
                switch error {
                case .error(let signatureError):
                    completion(false, signatureError?.getErrorDesc() ?? "")
                default:
                    completion(false, "generic_error_txt")
                }
            }
    }
}
