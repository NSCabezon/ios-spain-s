import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class GetOrderDetailUseCase: UseCase<GetOrderDetailUseCaseInput, GetOrderDetailUseCaseOkOutput, GetOrderDetailUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetOrderDetailUseCaseInput) throws -> UseCaseResponse<GetOrderDetailUseCaseOkOutput, GetOrderDetailUseCaseErrorOutput> {
        let stockManager = provider.getBsanStocksManager()
        let response = try stockManager.getOrderDetail(order: requestValues.order, stockAccountDTO: requestValues.stockAccount)
        if response.isSuccess(), case let data?? = try response.getResponseData() {
            let orderDetail = OrderDetail.create(from: data)
            return UseCaseResponse.ok(GetOrderDetailUseCaseOkOutput(orderDetail: orderDetail))
        } else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(GetOrderDetailUseCaseErrorOutput(errorDescription))
        }
    }
    
}

struct GetOrderDetailUseCaseInput {
    
    let stockAccount: StockAccountDTO
    let order: OrderDTO
    
    init(stockAccount: StockAccount, order: Order) {
        self.stockAccount = stockAccount.stockAccountDTO
        self.order = order.orderDTO
    }
    
}

struct GetOrderDetailUseCaseOkOutput {
    
    let orderDetail: OrderDetail
    
}

class GetOrderDetailUseCaseErrorOutput: StringErrorOutput {
    
}
