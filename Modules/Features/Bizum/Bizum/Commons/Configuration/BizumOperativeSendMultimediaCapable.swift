//
//  BizumOperativeSendSimpleMultimediaCapable.swift
//  Bizum
//
//  Created by José Carlos Estela Anguita on 10/12/20.
//

import CoreFoundationLib

protocol BizumOperativeSendSimpleMultimediaCapable {
    var dependenciesResolver: DependenciesResolver { get }
    var checkPayment: BizumCheckPaymentEntity { get }
    var receiverUserId: String { get }
    var multimedia: BizumMultimediaData? { get }
    var operationId: String { get }
    var operationType: BizumSendMultimediaOperationType { get }
}

extension BizumOperativeSendSimpleMultimediaCapable {
    
    var getMultimediaUsersUseCase: GetMultimediaUsersUseCase {
        return self.dependenciesResolver.resolve()
    }
    
    var sendMultimediaSimpleUseCase: SendMultimediaSimpleUseCase {
        return self.dependenciesResolver.resolve()
    }
    
    func sendSimpleMultimediaWithoutChecking() {
        let input = SendMultimediaSimpleInputUseCase(
            checkPayment: self.checkPayment,
            operationId: self.operationId,
            receiverUserId: self.receiverUserId,
            image: self.multimedia?.image,
            text: self.multimedia?.note,
            operationType: self.operationType
        )
        Scenario(useCase: self.sendMultimediaSimpleUseCase, input: input)
            .execute(on: self.dependenciesResolver.resolve())
    }
}

private extension BizumOperativeSendSimpleMultimediaCapable {
    
    func sendMultimedia(_ output: GetMultimediaUsersUseCaseOutput) -> Scenario<SendMultimediaSimpleInputUseCase, SendMultimediaSimpleUseCaseOkOutput, StringErrorOutput> {
        let input = SendMultimediaSimpleInputUseCase(
            checkPayment: self.checkPayment,
            operationId: self.operationId,
            receiverUserId: self.receiverUserId,
            image: self.multimedia?.image,
            text: self.multimedia?.note,
            operationType: self.operationType
        )
        return Scenario(useCase: self.sendMultimediaSimpleUseCase, input: input)
    }
}
