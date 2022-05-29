import Operative
import CoreFoundationLib

extension BizumDonationOperative: OperativeSignatureNavigationCapable {
    var signatureNavigationTitle: String {
        return "toolbar_title_bizum"
    }
}

extension BizumDonationOperative: OperativeSignatureTrackerCapable {
    var screenIdSignature: String {
        return BizumDonationSignaturePage().pageAssociated
    }
}

extension BizumDonationOperative: OperativeSignatureCapable {
    func performSignature(for presenter: SignaturePresentationDelegate,
                          completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = self.container else {
            completion(false, nil)
            return
        }
        guard let amount = operativeData.bizumSendMoney?.amount else {
            completion(false, nil)
            return
        }
        let operativeData: BizumDonationOperativeData = container.get()
        let signature: SignatureWithTokenEntity = container.get()
        let input = BizumValidateMoneyTransferOTPInputUseCase(
            checkPayment: operativeData.bizumCheckPaymentEntity,
            signatureWithToken: signature,
            amount: amount,
            numberOfRecipients: 1,
            account: operativeData.accountEntity,
            footPrint: nil,
            deviceToken: nil)
        let useCase = self.dependencies.resolve(for: BizumValidateMoneyTransferOTPUseCase.self)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess { response in
                let validateMoneyTransferOTPEntity = response.validateMoneyTransferOTPEntity
                operativeData.validateMoneyTransferOTPEntity = validateMoneyTransferOTPEntity
                container.save(operativeData)
                container.save(validateMoneyTransferOTPEntity.otp)
                completion(true, nil)
            }.onError { error in
                switch error {
                case .error(let signatureError):
                    completion(false, signatureError)
                default:
                    completion(false, nil)
                }
            }
    }
}
