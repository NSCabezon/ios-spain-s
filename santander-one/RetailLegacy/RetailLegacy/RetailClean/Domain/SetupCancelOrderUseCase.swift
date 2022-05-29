import SANLegacyLibrary
import CoreFoundationLib

class SetupCancelOrderUseCase: SetupUseCase<SetupCancelOrderUseCaseInput, SetupCancelOrderUseCaseOKOutput, SetupCancelOrderUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(repository: AppConfigRepository, managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
        super.init(appConfigRepository: repository)
    }
    
    override func executeUseCase(requestValues: SetupCancelOrderUseCaseInput) throws -> UseCaseResponse<SetupCancelOrderUseCaseOKOutput, SetupCancelOrderUseCaseErrorOutput> {
        
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        
        let stocksManager = provider.getBsanStocksManager()
        let stockAccountDTO = requestValues.stockAccount.stockAccountDTO
        let orderDTO = requestValues.order.orderDTO
        
        let removeResponse = try stocksManager.removeOrderDetail(order: orderDTO, stockAccountDTO: stockAccountDTO)
        
        guard removeResponse.isSuccess() else {
            return UseCaseResponse.error(SetupCancelOrderUseCaseErrorOutput(try removeResponse.getErrorMessage()))
        }
        
        let response = try stocksManager.getOrderDetail(order: orderDTO, stockAccountDTO: stockAccountDTO)
        
        guard response.isSuccess(), let dto = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(SetupCancelOrderUseCaseErrorOutput(errorDescription))
        }
        var orderDetail: OrderDetail?
        if let dto = dto {
            orderDetail = OrderDetail.create(from: dto)
        }
        return UseCaseResponse.ok(SetupCancelOrderUseCaseOKOutput(operativeConfig: operativeConfig, orderDetail: orderDetail))
    }
}

struct SetupCancelOrderUseCaseInput {
    let stockAccount: StockAccount
    let order: Order
}

struct SetupCancelOrderUseCaseOKOutput {
    var operativeConfig: OperativeConfig
    let orderDetail: OrderDetail?
}

extension SetupCancelOrderUseCaseOKOutput: SetupUseCaseOkOutputProtocol {}

class SetupCancelOrderUseCaseErrorOutput: StringErrorOutput {
    
}
