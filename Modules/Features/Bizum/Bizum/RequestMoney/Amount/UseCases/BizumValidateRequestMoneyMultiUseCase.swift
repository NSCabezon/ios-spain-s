//
//  BizumValidateRequestMoneyMultiUseCase.swift
//  Bizum
//
//  Created by Jose Ignacio de Juan Díaz on 03/12/2020.
//

import Foundation
import SANLibraryV3
import CoreFoundationLib

class BizumValidateRequestMoneyMultiUseCase: UseCase<BizumValidateRequestMoneyMultiUseCaseInput, BizumValidateRequestMoneyMultiUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider

    init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: BizumValidateRequestMoneyMultiUseCaseInput) throws -> UseCaseResponse<BizumValidateRequestMoneyMultiUseCaseOkOutput, StringErrorOutput> {
        let input = BizumValidateMoneyRequestMultiInputParams(checkPayment: requestValues.checkPayment.dto,
            document: requestValues.document.dto,
            dateTime: requestValues.dateTime,
            concept: requestValues.concept,
            amount: requestValues.amount,
            receiverUserIds: requestValues.receiversUserIds)
        let response = try self.provider.getBSANBizumManager().validateMoneyRequestMulti(input)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return .error(StringErrorOutput(errorDescription))
        }
        return UseCaseResponse.ok(BizumValidateRequestMoneyMultiUseCaseOkOutput(validateMoneyRequestMultiEntity: BizumValidateMoneyRequestMultiEntity(data)))
    }
}

struct BizumValidateRequestMoneyMultiUseCaseInput {
    let checkPayment: BizumCheckPaymentEntity
    let document: BizumDocumentEntity
    let dateTime: Date
    let concept: String
    let amount: String
    let receiversUserIds: [String]
}

struct BizumValidateRequestMoneyMultiUseCaseOkOutput {
    let validateMoneyRequestMultiEntity: BizumValidateMoneyRequestMultiEntity
}
