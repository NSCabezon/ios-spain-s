//
//  BizumValidateRequestMoneyUseCase.swift
//  Bizum
//
//  Created by Jose Ignacio de Juan Díaz on 03/12/2020.
//

import Foundation
import SANLibraryV3
import CoreFoundationLib

final class BizumValidateRequestMoneyUseCase: UseCase<BizumValidateRequestMoneyUseCaseInput, BizumValidateRequestMoneyUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: BizumValidateRequestMoneyUseCaseInput) throws -> UseCaseResponse<BizumValidateRequestMoneyUseCaseOkOutput, StringErrorOutput> {
        let input = BizumValidateMoneyRequestInputParams(checkPayment: requestValues.checkPayment.dto,
                                                         document: requestValues.document.dto,
                                                         dateTime: requestValues.dateTime,
                                                         concept: requestValues.concept,
                                                         amount: requestValues.amount,
                                                         receiverUserId: requestValues.receiverUserId)
        let response = try self.provider.getBSANBizumManager().validateMoneyRequest(input)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return .error(StringErrorOutput(errorDescription))
        }
        let entity = BizumValidateMoneyRequestEntity(data)
        let codeInfo = entity.transferInfo.codInfo ?? ""
        return UseCaseResponse.ok(BizumValidateRequestMoneyUseCaseOkOutput(validateMoneyRequestEntity: entity,
                                                                           userRegistered: isUserRegistered(codeInfo)))
    }
}

private extension BizumValidateRequestMoneyUseCase {
    func isUserRegistered(_ code: String) -> Bool {
        let noRegisterCode = "PAINOP_CJ00009"
        return code.trim() != noRegisterCode
    }
}

struct BizumValidateRequestMoneyUseCaseInput {
    let checkPayment: BizumCheckPaymentEntity
    let document: BizumDocumentEntity
    let dateTime: Date
    let concept: String
    let amount: String
    let receiverUserId: String
}

struct BizumValidateRequestMoneyUseCaseOkOutput {
    let validateMoneyRequestEntity: BizumValidateMoneyRequestEntity
    let userRegistered: Bool
}
