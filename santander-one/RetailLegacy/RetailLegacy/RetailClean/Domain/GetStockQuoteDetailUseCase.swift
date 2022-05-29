import SANLegacyLibrary
import CoreFoundationLib

class GetStockQuoteDetailUseCase: UseCase<GetStockQuoteDetailUseCaseInput, GetStockQuoteDetailUseCaseOkOutput, GetStockQuoteDetailUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    var canceled: Bool = false

    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetStockQuoteDetailUseCaseInput) throws -> UseCaseResponse<GetStockQuoteDetailUseCaseOkOutput, GetStockQuoteDetailUseCaseErrorOutput> {
        let stock = requestValues.stock
        let stocksManager = provider.getBsanStocksManager()
        do {
            let response = try stocksManager.getQuoteDetail(stockQuoteDTO: stock.quoteDto)
            if response.isSuccess(), let quoteDetailDto = try response.getResponseData() {
                stock.setQuoteDetailDto(quoteDetailDto: quoteDetailDto)
                stock.state = .done
                return UseCaseResponse.ok(GetStockQuoteDetailUseCaseOkOutput(stock: stock))
            }
            let errorDescription = try response.getErrorMessage() ?? ""
            stock.state = .error
            return UseCaseResponse.error(GetStockQuoteDetailUseCaseErrorOutput(stock: stock, errorDesc: errorDescription))
        } catch {
            stock.state = .error
            return UseCaseResponse.error(GetStockQuoteDetailUseCaseErrorOutput(stock: stock, errorDesc: ""))
        }
    }
}

struct GetStockQuoteDetailUseCaseInput {
    let stock: StockBase
}

struct GetStockQuoteDetailUseCaseOkOutput {
    let stock: StockBase
}

class GetStockQuoteDetailUseCaseErrorOutput: StringErrorOutput {
    let stock: StockBase
    
    init(stock: StockBase, errorDesc: String?) {
        self.stock = stock
        super.init(errorDesc)
    }
}
