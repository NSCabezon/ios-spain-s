import Foundation
import CoreFoundationLib

final class SendAmountUseCaseStrategy: AmountUseCaseStrategy {
    var dependenciesResolver: DependenciesResolver
    var operativeData: BizumSendMoneyOperativeData?
    let checkPayment: BizumCheckPaymentEntity
    let document: BizumDocumentEntity
    let concept: String?
    let amount: String
    let receivers: [String]
    let account: AccountEntity?

    init(dependenciesResolver: DependenciesResolver, operativeData: BizumSendMoneyOperativeData?, checkPayment: BizumCheckPaymentEntity, document: BizumDocumentEntity, concept: String?, amount: String, receivers: [String], account: AccountEntity?) {
        self.dependenciesResolver = dependenciesResolver
        self.operativeData = operativeData
        self.checkPayment = checkPayment
        self.document = document
        self.concept = concept
        self.amount = amount
        self.receivers = receivers
        self.account = account
    }
    
    func executeSimpleAmountUseCase(completion: @escaping () -> Void, onFailure: @escaping (String?) -> Void) {
        guard let receiver = receivers.first else { return }
        let requestValues = BizumSimpleSendMoneyInputUseCase(
            checkPayment: checkPayment,
            document: document,
            concept: concept,
            amount: amount,
            receiverUserId: receiver,
            account: self.operativeData?.accountEntity
        )
        let useCase: BizumValidateMoneyTransferUseCase = dependenciesResolver.resolve()
        UseCaseWrapper(with: useCase.setRequestValues(requestValues: requestValues),
                       useCaseHandler: self.dependenciesResolver.resolve(),
                       onSuccess: { [weak self] response in
                        self?.simpleSendMoneySuccess(response)
                        completion()
                       }, onError: { error in
                        let errorMessage = error.getErrorDesc()
                        onFailure(errorMessage)
                       })
    }

    func executeMultipleAmountUseCase(completion: @escaping () -> Void, onFailure: @escaping (String?) -> Void) {
        let requestValues = BizumValidateMoneyTransferInputUseCase(checkPayment: self.checkPayment,
                                                               document: self.document,
                                                               concept: self.concept,
                                                               amount: self.amount,
                                                               receiverUserIds: self.receivers,
                                                               account: self.account)
        let useCase: BizumValidateMoneyTransferMultiUseCase = dependenciesResolver.resolve()
        UseCaseWrapper(with: useCase.setRequestValues(requestValues: requestValues),
                       useCaseHandler: self.dependenciesResolver.resolve(),
                       onSuccess: { [weak self] response in
                        self?.multipleSendMoneySuccess(response)
                        completion()
                       }, onError: { error in
                        let errorMessage = error.getErrorDesc()
                        onFailure(errorMessage)
                       })
    }
}

private extension SendAmountUseCaseStrategy {
    func simpleSendMoneySuccess(_ response: BizumSimpleSendMoneyUseCaseOkOutput) {
         self.operativeData?.bizumValidateMoneyTransferEntity = response.bizumValidateMoneyTransferEntity
         self.operativeData?.bizumValidateMoneyTransferMultiEntity = nil
         if response.userRegistered {
             self.operativeData?.typeUserInSimpleSend = .register
         } else {
            self.operativeData?.typeUserInSimpleSend = .noRegister
        }
     }

    func multipleSendMoneySuccess(_ response: BizumMultipleSendMoneyUseCaseOkOutput) {
        self.operativeData?.typeUserInSimpleSend = .register
        self.operativeData?.bizumValidateMoneyTransferMultiEntity = response.validateMoneyTransferMulti
        self.operativeData?.bizumValidateMoneyTransferEntity = nil
    }
}
