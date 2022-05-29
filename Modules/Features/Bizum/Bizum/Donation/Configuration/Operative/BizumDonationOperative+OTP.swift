import Operative
import CoreFoundationLib

extension BizumDonationOperative: OperativeOTPNavigationCapable {
    var otpNavigationTitle: String {
        return "toolbar_title_bizum"
    }
}

extension BizumDonationOperative: OperativeOTPTrackerCapable {
    var screenIdOtp: String {
        return BizumDonationOTPPage().pageAssociated
    }
}

extension BizumDonationOperative: OperativeOTPCapable {
    func performOTP(for presenter: OTPPresentationDelegate,
                    completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        guard let container = self.container else {
            completion(false, nil)
            return
        }
        let operativeData: BizumDonationOperativeData = container.get()
        guard operativeData.validateMoneyTransferOTPEntity != nil else {
            completion(false, nil)
            return
        }
        self.performGetMultimediaUsers()
        self.performSimpleOTP(for: presenter, completion: completion)
    }

    func performGetMultimediaUsers() {
        guard let container = self.container else {
            return
        }
        let operativeData: BizumDonationOperativeData = container.get()
        guard let multimediaData = operativeData.multimediaData, multimediaData.hasSomeValue(),
              let organization = operativeData.organization else {
            return
        }
        let input = GetMultimediaUsersInputUseCase(checkPayment: operativeData.bizumCheckPaymentEntity,
                                                   contacts: [organization.identifier])
        Scenario(useCase: self.dependencies.resolve(for: GetMultimediaUsersUseCase.self), input: input)
            .execute(on: self.dependencies.resolve(for: UseCaseHandler.self))
            .onSuccess { [weak self] result in
                let contacts = result.multimediaContactsEntity.contacts
                guard let contact = contacts.first else { return }
                self?.performSendMultimedia(contact)
            }
    }

    func performSendMultimedia(_ contact: MultimediaCapacityEntity?) {
        guard let contact = contact, contact.capacity, let container = self.container else {
            return
        }
        let operativeData: BizumDonationOperativeData = container.get()
        guard let validateMoneyTransferEntity = operativeData.bizumValidateMoneyTransferEntity else {
            return
        }
        let input = SendMultimediaSimpleInputUseCase(checkPayment: operativeData.bizumCheckPaymentEntity,
                                                     operationId: validateMoneyTransferEntity.operationId,
                                                     receiverUserId: contact.phone,
                                                     image: operativeData.multimediaData?.image,
                                                     text: operativeData.multimediaData?.note,
                                                     operationType: .send)
        let useCase = self.dependencies.resolve(for: SendMultimediaSimpleUseCase.self)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependencies.resolve(for: UseCaseHandler.self))
    }

    func performSimpleOTP(for presenter: OTPPresentationDelegate,
                          completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        guard let container = self.container else {
            completion(false, nil)
            return
        }
        let operativeData: BizumDonationOperativeData = container.get()
        let otpValidation: OTPValidationEntity = container.get()
        guard let document = operativeData.document else {
            completion(false, nil)
            return
        }
        guard let amount = operativeData.bizumSendMoney?.amount,
              let concept = operativeData.bizumSendMoney?.concept else {
            completion(false, nil)
            return
        }
        guard let bizumValidateMoneyTransferEntity = operativeData.bizumValidateMoneyTransferEntity else {
            completion(false, nil)
            return
        }
        let input = BizumMoneyTransferOTPInputUseCase(
            checkPayment: operativeData.bizumCheckPaymentEntity,
            otpValidation: otpValidation,
            document: document,
            otpCode: presenter.code,
            validateMoneyTransfer: bizumValidateMoneyTransferEntity,
            dateTime: Date(),
            concept: concept,
            amount: amount,
            receiverUserId: operativeData.organization?.identifier ?? "",
            account: operativeData.accountEntity,
            tokenPush: ""
        )
        let useCase = self.dependencies.resolve(for: BizumMoneyTransferOTPUseCase.self)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess { _ in
                completion(true, nil)
            }
            .onError { error in
                switch error {
                case .error(error: let otpError):
                    completion(false, otpError)
                default:
                    completion(false, nil)
                }
            }
    }
}
