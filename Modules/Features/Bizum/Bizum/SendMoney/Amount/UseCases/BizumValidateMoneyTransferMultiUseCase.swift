import Foundation
import CoreFoundationLib
import SANLibraryV3

final public class BizumValidateMoneyTransferMultiUseCase: UseCase<BizumValidateMoneyTransferInputUseCase, BizumMultipleSendMoneyUseCaseOkOutput, StringErrorOutput> {
    let dependencies: DependenciesResolver
    private let provider: BSANManagersProvider

    public init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
        self.provider = self.dependencies.resolve(for: BSANManagersProvider.self)
    }

    override public func executeUseCase(requestValues: BizumValidateMoneyTransferInputUseCase) throws -> UseCaseResponse<BizumMultipleSendMoneyUseCaseOkOutput, StringErrorOutput> {
        let bizumValidateMoneyRequestMultiInputDTO = generateInput(input: requestValues)
        let response = try self.provider.getBSANBizumManager()
            .validateMoneyTransferMulti(bizumValidateMoneyRequestMultiInputDTO)
        if response.isSuccess(), let responseDTO = try response.getResponseData() {
            let entity = BizumValidateMoneyTransferMultiEntity(responseDTO)
            let output = BizumMultipleSendMoneyUseCaseOkOutput(validateMoneyTransferMulti: entity)
            return UseCaseResponse.ok(output)
        } else {
            return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage()))
        }
    }
}

private extension BizumValidateMoneyTransferMultiUseCase {
    func generateInput(input: BizumValidateMoneyTransferInputUseCase) -> BizumValidateMoneyTransferMultiInputParams {
        let params = BizumValidateMoneyTransferMultiInputParams(
            checkPayment: input.checkPayment.dto,
            document: input.document.dto,
            dateTime: Date(),
            concept: input.concept ?? "",
            amount: input.amount,
            receiverUserIds: input.receiverUserIds,
            account: input.account?.dto
        )
        return params
    }
}

public struct BizumValidateMoneyTransferInputUseCase {
    let checkPayment: BizumCheckPaymentEntity
    let document: BizumDocumentEntity
    let concept: String?
    let amount: String
    let receiverUserIds: [String]
    let account: AccountEntity?
}

public struct BizumMultipleSendMoneyUseCaseOkOutput {
    let validateMoneyTransferMulti: BizumValidateMoneyTransferMultiEntity
}
