import CoreFoundationLib
import SANLibraryV3

// MARK: - BizumOperationMultipleDetailUseCase

final class BizumOperationMultipleDetailUseCase: UseCase<BizumOperationMultipleDetailUseCaseInput, BizumOperationMultipleDetailUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }

    override func executeUseCase(requestValues: BizumOperationMultipleDetailUseCaseInput) throws -> UseCaseResponse<BizumOperationMultipleDetailUseCaseOkOutput, StringErrorOutput> {
        let params = BizumOperationMultipleListDetailInputParams(checkPayment: requestValues.checkPayment.dto,
                                                                 operation: requestValues.operation.dto)
        let response = try self.provider.getBSANBizumManager().getListMultipleDetailOperation(params)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let message = try response.getErrorMessage()
            return .error(StringErrorOutput(message))
        }
        let detail = BizumOperationMultiDetailEntity(data)
        return .ok(BizumOperationMultipleDetailUseCaseOkOutput(detail: detail))
    }
}

// MARK: - BizumOperationMultipleDetailUseCaseInput

struct BizumOperationMultipleDetailUseCaseInput {
    let checkPayment: BizumCheckPaymentEntity
    let operation: BizumOperationMultiEntity
}

// MARK: - BizumOperationMultipleDetailUseCaseOkOutput

struct BizumOperationMultipleDetailUseCaseOkOutput {
    let detail: BizumOperationMultiDetailEntity
}
