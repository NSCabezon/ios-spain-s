import CoreFoundationLib
import CoreDomain
import Foundation
import SANLegacyLibrary

class GetOrderListFilteredUseCase: UseCase<GetOrderListUseCaseInput, GetOrderListUseCaseOkOutput, GetOrderListUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetOrderListUseCaseInput) throws -> UseCaseResponse<GetOrderListUseCaseOkOutput, GetOrderListUseCaseErrorOutput> {
        let stockManager = provider.getBsanStocksManager()
        
        let dateRange: DateFilter?
        if requestValues.dateFilter == nil {
            dateRange = DateFilter.getDateFilterFor(numberOfYears: -1)
        } else {
            dateRange = requestValues.dateFilter?.dto
        }
        if dateRange?.fromDateModel != nil && dateRange?.toDateModel == nil {
            dateRange?.toDateModel = DateModel(date: Date())
        }

        let response = try stockManager.getOrdenes(stockAccountDTO: requestValues.stockAccount.stockAccountDTO, pagination: requestValues.pagination?.dto, dateFilter: dateRange)
        if response.isSuccess(), let data = try response.getResponseData(), let transactions = data.orders?.map({Order.create($0)}) {
            let result: [Order]
            if let status = convertOrderSituation(status: requestValues.orderStatus) {
                result = transactions.filter({ $0.situation == status })
            } else {
                result = transactions
            }
            return UseCaseResponse.ok(GetOrderListUseCaseOkOutput(orderList: result, pagination: PaginationDO(dto: data.pagination)))
        } else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(GetOrderListUseCaseErrorOutput(errorDescription))
        }
    }
    
    private func convertOrderSituation(status: OrderSituationFilter?) -> OrderStatus? {
        switch status {
        case .all?:
            return nil
        case .negotiated?:
            return .negotiated
        case .executed?:
            return .executed
        case .pending?:
            return .pending
        case .rejected?:
            return .rejected
        case .cancelled?:
            return .cancelled
        default:
            return nil
        }
    }
}
