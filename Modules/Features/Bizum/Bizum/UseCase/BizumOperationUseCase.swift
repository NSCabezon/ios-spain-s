import CoreFoundationLib
import SANLibraryV3

typealias BizumOperationUseCaseAlias = UseCase<BizumOperationUseCaseInput, BizumOperationUseCaseOkOutput, StringErrorOutput>

final class BizumOperationUseCase: BizumOperationUseCaseAlias {
    private let provider: BSANManagersProvider
    private var phone: String?
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }

    override public func executeUseCase(requestValues: BizumOperationUseCaseInput) throws -> UseCaseResponse<BizumOperationUseCaseOkOutput, StringErrorOutput> {
        let dateTo = Date().endOfDay()
        let dateFrom = dateTo.addMonth(months: -1).startOfDay()
        let params = BizumOperationsInputParams(
            checkPayment: requestValues.checkPayment.dto,
            page: requestValues.page,
            dateFrom: dateFrom,
            dateTo: dateTo,
            orderBy: requestValues.orderBy?.rawValue,
            orderType: requestValues.orderType?.rawValue
        )
        let response = try self.provider.getBSANBizumManager().getOperations(params)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let message = try response.getErrorMessage()
            return .error(StringErrorOutput(message))
        }
        let isMoreData = data.moreData == "1"
        self.phone = requestValues.checkPayment.phone
        let operations = data.operations
            .map(BizumOperationEntity.init)
            .filter { !($0.receptorId ?? "").isEmpty }
        let totalPages = data.pagesTotal ?? BizumConstants.maxTotalPages
        return .ok(BizumOperationUseCaseOkOutput(operations: operations, isMoreData: isMoreData, totalPages: totalPages))
    }
}

enum BizumOperationUseCaseOrderBy: String {
    case dischargeDate = "FECHA_ALTA"
}

enum BizumOperationUseCaseOrderType: String {
    case descendant = "DESC"
}

struct BizumOperationUseCaseInput {
    let page: Int
    let checkPayment: BizumCheckPaymentEntity
    let orderBy: BizumOperationUseCaseOrderBy?
    let orderType: BizumOperationUseCaseOrderType?
}

struct BizumOperationUseCaseOkOutput {
    let operations: [BizumOperationEntity]
    let isMoreData: Bool
    let totalPages: Int
}
