//
//  BizumRequestMoneyMultiUseCase.swift
//  Bizum
//
//  Created by Jose Ignacio de Juan Díaz on 02/12/2020.
//

import Foundation
import SANLibraryV3
import SANLegacyLibrary
import CoreFoundationLib

class BizumRequestMoneyMultiUseCase: UseCase<BizumRequestMoneyMultiUseCaseInput, BizumRequestMoneyMultiUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: SANLibraryV3.BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: SANLibraryV3.BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: BizumRequestMoneyMultiUseCaseInput) throws -> UseCaseResponse<BizumRequestMoneyMultiUseCaseOkOutput, StringErrorOutput> {
        let input = BizumMoneyRequestMultiInputParams(checkPayment: requestValues.checkPayment.dto,
                                                      document: requestValues.document.dto,
                                                      dateTime: requestValues.dateTime,
                                                      concept: requestValues.concept,
                                                      amount: requestValues.amount,
                                                      operationId: requestValues.operationId,
                                                      actions: requestValues.actions)
        let response = try self.provider.getBSANBizumManager().moneyRequestMulti(input)
        guard
            response.isSuccess(),
            let data = try response.getResponseData(),
            data.errorCode == "0" else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return .error(StringErrorOutput(errorDescription))
        }
        return UseCaseResponse.ok(BizumRequestMoneyMultiUseCaseOkOutput(moneyRequestMultiEntity: BizumMoneyRequestMultiEntity(data)))
    }
    
}

struct BizumRequestMoneyMultiUseCaseInput {
    let checkPayment: BizumCheckPaymentEntity
    let document: BizumDocumentEntity
    let dateTime: Date
    let concept: String
    let amount: String
    let operationId: String
    let actions: [BizumMoneyRequestMultiActionInputParam]
}

struct BizumRequestMoneyMultiUseCaseOkOutput {
    let moneyRequestMultiEntity: BizumMoneyRequestMultiEntity
}
