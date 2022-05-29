import SANLegacyLibrary
import CoreFoundationLib

class GetStocksUseCase: UseCase<GetStocksUseCaseInput, GetStocksUseCaseOkOutput, GetStocksUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    var canceled: Bool = false

    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetStocksUseCaseInput) throws -> UseCaseResponse<GetStocksUseCaseOkOutput, GetStocksUseCaseErrorOutput> {
        let stocksManager = provider.getBsanStocksManager()
        let response = try stocksManager.getAllStocks(stockAccountDTO: requestValues.account.stockAccountDTO)
        if response.isSuccess(), let data = try response.getResponseData(), let list = data.stockListDTO, !canceled {
            return UseCaseResponse.ok(GetStocksUseCaseOkOutput(stocks: list.map({Stock(dto: $0)})))
        }
        
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(GetStocksUseCaseErrorOutput(errorDescription))
    }
}

extension GetStocksUseCase: Cancelable {
    func cancel() {
        canceled = true
    }
}

struct GetStocksUseCaseInput {
    let account: StockAccount
}

struct GetStocksUseCaseOkOutput {
    let stocks: [Stock]
}

class GetStocksUseCaseErrorOutput: StringErrorOutput {
    
}
