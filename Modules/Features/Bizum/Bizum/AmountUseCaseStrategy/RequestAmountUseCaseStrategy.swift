import Foundation
import CoreFoundationLib

final class RequestAmountUseCaseStrategy: AmountUseCaseStrategy {
    var dependenciesResolver: DependenciesResolver
    let operativeData: BizumRequestMoneyOperativeData
    let checkPayment: BizumCheckPaymentEntity
    let document: BizumDocumentEntity
    let concept: String?
    let amount: String
    let receivers: [String]

    init(dependenciesResolver: DependenciesResolver, operativeData: BizumRequestMoneyOperativeData, checkPayment: BizumCheckPaymentEntity, document: BizumDocumentEntity, concept: String?, amount: String, receivers: [String]) {
        self.dependenciesResolver = dependenciesResolver
        self.operativeData = operativeData
        self.checkPayment = checkPayment
        self.document = document
        self.concept = concept
        self.amount = amount
        self.receivers = receivers
    }

    func executeSimpleAmountUseCase(completion: @escaping () -> Void, onFailure: @escaping (String?) -> Void) {
        guard let receiver = receivers.first else { return }
        let requestValues = BizumValidateRequestMoneyUseCaseInput(checkPayment: checkPayment,
                                                                  document: document,
                                                                  dateTime: Date(),
                                                                  concept: concept ?? "",
                                                                  amount: amount,
                                                                  receiverUserId: receiver)
        let useCase: BizumValidateRequestMoneyUseCase = dependenciesResolver.resolve()
        useCase.setRequestValues(requestValues: requestValues)
        UseCaseWrapper(with: useCase,
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
        let requestValues = BizumValidateRequestMoneyMultiUseCaseInput(checkPayment: checkPayment,
                                                                       document: document,
                                                                       dateTime: Date(), concept: concept ?? "",
                                                                       amount: amount, receiversUserIds: receivers)
        let useCase: BizumValidateRequestMoneyMultiUseCase = dependenciesResolver.resolve()
        useCase.setRequestValues(requestValues: requestValues)
        UseCaseWrapper(with: useCase,
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

private extension RequestAmountUseCaseStrategy {
    func simpleSendMoneySuccess(_ response: BizumValidateRequestMoneyUseCaseOkOutput) {
        self.operativeData.bizumValidateMoneyRequestEntity = response.validateMoneyRequestEntity
        self.operativeData.bizumValidateMoneyRequestMultiEntity = nil
        if response.userRegistered {
            self.operativeData.typeUserInSimpleSend = .register
        } else {
           self.operativeData.typeUserInSimpleSend = .noRegister
       }
     }

    func multipleSendMoneySuccess(_ response: BizumValidateRequestMoneyMultiUseCaseOkOutput) {
        self.operativeData.bizumValidateMoneyRequestEntity = nil
        self.operativeData.bizumValidateMoneyRequestMultiEntity = response.validateMoneyRequestMultiEntity
    }
}
