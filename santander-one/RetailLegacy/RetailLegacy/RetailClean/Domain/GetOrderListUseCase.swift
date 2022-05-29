import CoreFoundationLib
import CoreDomain
import Foundation
import SANLegacyLibrary

class GetOrderListUseCase: UseCase<GetOrderListUseCaseInput, GetOrderListUseCaseOkOutput, GetOrderListUseCaseErrorOutput> {
    
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
            return UseCaseResponse.ok(GetOrderListUseCaseOkOutput(orderList: transactions, pagination: PaginationDO(dto: data.pagination)))
        } else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(GetOrderListUseCaseErrorOutput(errorDescription))
        }
    }
    
}

struct GetOrderListUseCaseInput {
    let stockAccount: StockAccount
    let pagination: PaginationDO?
    let dateFilter: DateFilterDO?
    let orderStatus: OrderSituationFilter?
    
    init(stockAccount: StockAccount, pagination: PaginationDO?, dateFilter: DateFilterDO?, orderStatus: OrderSituationFilter? = nil) {
        self.stockAccount = stockAccount
        self.pagination = pagination
        self.dateFilter = dateFilter
        self.orderStatus = orderStatus
    }
}

struct GetOrderListUseCaseOkOutput {
    
    let orderList: [Order]
    let pagination: PaginationDO?
    
}

class GetOrderListUseCaseErrorOutput: StringErrorOutput {
    
}
