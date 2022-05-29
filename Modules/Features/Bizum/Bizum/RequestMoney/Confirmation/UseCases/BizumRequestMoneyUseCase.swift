//
//  BizumRequestMoneyUseCase.swift
//  Bizum
//
//  Created by Jose Ignacio de Juan Díaz on 02/12/2020.
//

import Foundation
import SANLibraryV3
import CoreFoundationLib

class BizumRequestMoneyUseCase: UseCase<BizumRequestMoneyUseCaseInput, BizumRequestMoneyUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: BizumRequestMoneyUseCaseInput) throws -> UseCaseResponse<BizumRequestMoneyUseCaseOkOutput, StringErrorOutput> {
        let input = BizumMoneyRequestInputParams(checkPayment: requestValues.checkPayment.dto,
                                                 document: requestValues.document.dto,
                                                 operationId: requestValues.operationId,
                                                 dateTime: requestValues.dateTime,
                                                 concept: requestValues.concept,
                                                 amount: requestValues.amount,
                                                 receiverUserId: requestValues.receiverUserId)
        let response = try self.provider.getBSANBizumManager().moneyRequest(input)
        guard
            response.isSuccess(),
            let data = try response.getResponseData(),
            data.transferInfo.errorCode == "0" else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return .error(StringErrorOutput(errorDescription))
        }
        return UseCaseResponse.ok(BizumRequestMoneyUseCaseOkOutput(moneyRequestEntity: BizumMoneyRequestEntity(data)))
    }
}

struct BizumRequestMoneyUseCaseInput {
    let checkPayment: BizumCheckPaymentEntity
    let document: BizumDocumentEntity
    let operationId: String
    let dateTime: Date
    let concept: String
    let amount: String
    let receiverUserId: String
}

struct BizumRequestMoneyUseCaseOkOutput {
    let moneyRequestEntity: BizumMoneyRequestEntity
}
