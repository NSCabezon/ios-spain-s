import CoreFoundationLib
import SANLibraryV3

// MARK: - BizumOperationListMultipleUseCase

final class BizumOperationListMultipleUseCase: UseCase<BizumOperationListMultipleUseCaseInput, BizumOperationListMultipleUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }

    override func executeUseCase(requestValues: BizumOperationListMultipleUseCaseInput) throws -> UseCaseResponse<BizumOperationListMultipleUseCaseOkOutput, StringErrorOutput> {
        let dateTo = Date().endOfDay()
        let dateFrom = dateTo.addMonth(months: -1).startOfDay()
        let params = BizumOperationListMultipleInputParams(checkPayment: requestValues.checkPayment.dto,
                                                           formDate: dateFrom,
                                                           toDate: dateTo,
                                                           page: requestValues.page,
                                                           elements: 100)
        let response = try self.provider.getBSANBizumManager().getListMultipleOperations(params)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let message = try response.getErrorMessage()
            return .error(StringErrorOutput(message))
        }
        let isMoreData = data.moreData == "1"
        let operations = data.operations.map { BizumOperationMultiEntity($0) }
        let totalPages = data.pagesTotal ?? BizumConstants.maxTotalPages
        return .ok(BizumOperationListMultipleUseCaseOkOutput(operations: operations, isMoreData: isMoreData, totalPages: totalPages))
    }
}

// MARK: - BizumOperationListMultipleUseCaseInput

struct BizumOperationListMultipleUseCaseInput {
    let page: Int
    let checkPayment: BizumCheckPaymentEntity
}

// MARK: - BizumOperationListMultipleUseCaseOkOutput

struct BizumOperationListMultipleUseCaseOkOutput {
    let operations: [BizumOperationMultiEntity]
    let isMoreData: Bool
    let totalPages: Int
}
