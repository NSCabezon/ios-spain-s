import Foundation
import CoreFoundationLib
import SANLibraryV3

public struct BizumSimpleSendMoneyInputUseCase {
    let checkPayment: BizumCheckPaymentEntity
    let document: BizumDocumentEntity
    let concept: String?
    let amount: String
    let receiverUserId: String
    let account: AccountEntity?
}

public struct BizumSimpleSendMoneyUseCaseOkOutput {
    let bizumValidateMoneyTransferEntity: BizumValidateMoneyTransferEntity
    let userRegistered: Bool
}

public final class BizumValidateMoneyTransferUseCase: UseCase<BizumSimpleSendMoneyInputUseCase, BizumSimpleSendMoneyUseCaseOkOutput, StringErrorOutput> {
    let dependencies: DependenciesResolver
    private let provider: BSANManagersProvider

    public init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
        self.provider = self.dependencies.resolve(for: BSANManagersProvider.self)
    }

    override public func executeUseCase(requestValues: BizumSimpleSendMoneyInputUseCase) throws -> UseCaseResponse<BizumSimpleSendMoneyUseCaseOkOutput, StringErrorOutput> {
        let bizumValidateMoneyRequestInputDTO = generateInput(input: requestValues)
        let response = try self.provider.getBSANBizumManager().validateMoneyTransfer(bizumValidateMoneyRequestInputDTO)
        if response.isSuccess(), let responseDTO = try response.getResponseData() {
            let entity = BizumValidateMoneyTransferEntity(responseDTO)
            let codeInfo = entity.transferInfo.codInfo ?? ""
            let output = BizumSimpleSendMoneyUseCaseOkOutput(bizumValidateMoneyTransferEntity: entity, userRegistered: isUserRegistered(codeInfo))
            return UseCaseResponse.ok(output)
        } else {
            return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage()))
        }
    }
}

private extension BizumValidateMoneyTransferUseCase {
    func generateInput(input: BizumSimpleSendMoneyInputUseCase) -> BizumValidateMoneyTransferInputParams {
        let params = BizumValidateMoneyTransferInputParams(checkPayment: input.checkPayment.dto,
                                                           document: input.document.dto,
                                                           dateTime: Date(),
                                                           concept: input.concept ?? "",
                                                           amount: input.amount,
                                                           receiverUserId: input.receiverUserId,
                                                           account: input.account?.dto)
        return params
    }

    func isUserRegistered(_ code: String) -> Bool {
        let noRegisterCode = "PAINOP_CJ00008"
        return code.trim() != noRegisterCode
    }
}
