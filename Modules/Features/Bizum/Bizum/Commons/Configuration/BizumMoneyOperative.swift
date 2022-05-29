import Operative
import CoreFoundationLib

protocol BizumMoneyOperative: BizumMoneyCommonSetups, OperativePresetupCapable, BizumCommonSetupCapable { }

extension BizumMoneyOperative {
    func performPreSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        guard let container = self.container else { return failed(OperativeSetupError(title: nil, message: nil)) }
        var operativeData: BizumMoneyOperativeData = container.get()
        let useCase = self.dependencies.resolve(for: BizumCommonPreSetupUseCaseProtocol.self)
        let scenario = Scenario(useCase: useCase, input: BizumCommonPreSetupUseCaseInput(bizumCheckPaymentEntity: operativeData.bizumCheckPaymentEntity, operationEntity: nil))
        self.bizumSetupWithScenario(scenario) { [weak self] result in
            operativeData.accountEntity = result.account
            operativeData.document = result.document
            operativeData.accounts = result.accounts
            container.save(operativeData)
            self?.dependencies.register(for: BizumCheckPaymentConfiguration.self) { _ in
                return BizumCheckPaymentConfiguration(bizumCheckPaymentEntity: operativeData.bizumCheckPaymentEntity)
            }
            success()
        }
    }
    
    /// Note: This method is not used in multimedia send since 5.4
    func performGetMultimediaUsers() {
        guard let container = self.container else {
            return
        }
        let operativeData: BizumSendMoneyOperativeData = container.get()
        guard let multimediaData = operativeData.multimediaData, multimediaData.hasSomeValue(),
            let contacts = operativeData.bizumContactEntity else {
                return
        }
        let phones: [String] = contacts.map({ $0.phone })
        let input = GetMultimediaUsersInputUseCase(checkPayment: operativeData.bizumCheckPaymentEntity,
                                                   contacts: phones)
        let useCase = self.dependencies.resolve(for: GetMultimediaUsersUseCase.self).setRequestValues(requestValues: input)
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: self.dependencies.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                let contacts = result.multimediaContactsEntity.contacts
                if contacts.count > 1 {
                    self?.performSendMultimedia(contacts)
                } else {
                    self?.performSendMultimedia(contacts.first)
                }
            })
    }
    
    // MARK: Simple
    func performSendMultimedia(_ contact: MultimediaCapacityEntity?) {
        guard let contact = contact, contact.capacity else {
            return
        }
        self.performSendMultimedia(contact.phone)
    }
    
    func performSendMultimedia(_ phone: String?) {
        guard let contactPhone = phone, let container = self.container else {
            return
        }
        let operativeData: BizumSendMoneyOperativeData = container.get()
        guard let validateMoneyTransferEntity = operativeData.bizumValidateMoneyTransferEntity else {
            return
        }
        let input = SendMultimediaSimpleInputUseCase(checkPayment: operativeData.bizumCheckPaymentEntity,
                                                     operationId: validateMoneyTransferEntity.operationId,
                                                     receiverUserId: contactPhone,
                                                     image: operativeData.multimediaData?.image,
                                                     text: operativeData.multimediaData?.note,
                                                     operationType: .send)
        let useCase = self.dependencies.resolve(for: SendMultimediaSimpleUseCase.self).setRequestValues(requestValues: input)
        UseCaseWrapper(with: useCase, useCaseHandler: self.dependencies.resolve(for: UseCaseHandler.self))
    }

    // MARK: Multiple
    func performSendMultimedia(_ contacts: [MultimediaCapacityEntity]) {
        guard let container = self.container else {
            return
        }
        let contactsAllowMultimedia = contacts.filter { $0.capacity }
        let phones: [String] = contactsAllowMultimedia.map { $0.phone }
        guard !phones.isEmpty else {
            return
        }
        self.performSendMultimedia(phones)
    }
    
    func performSendMultimedia(_ phones: [String]) {
        guard let container = self.container else {
            return
        }
        let operativeData: BizumSendMoneyOperativeData = container.get()
        guard
            let emitterId = operativeData.bizumCheckPaymentEntity.phone,
            let validateMoneyTransferMultiEntity = operativeData.bizumValidateMoneyTransferMultiEntity else {
            return
        }
        let receiversFiltered = validateMoneyTransferMultiEntity.validationResponseList.filter { phones.contains($0.identifier) }
        let sendMultimediaMultiReceivers = receiversFiltered.map {SendMultimediaMultiReceiverInput(receiverUserId: $0.identifier, operationId: $0.operationId)}
        let input = SendMultimediaMultiInputUseCase(emitterId: emitterId,
                                                    multiOperationId: validateMoneyTransferMultiEntity.multiOperationId,
                                                    receivers: sendMultimediaMultiReceivers,
                                                    image: operativeData.multimediaData?.image,
                                                    text: operativeData.multimediaData?.note,
                                                    operationType: .send)
        let useCase = self.dependencies.resolve(for: SendMultimediaMultiUseCase.self).setRequestValues(requestValues: input)
        UseCaseWrapper(with: useCase, useCaseHandler: self.dependencies.resolve(for: UseCaseHandler.self))
    }
}
