import SANLegacyLibrary
import CoreFoundationLib

class GetStockIbexSanUseCase: UseCase<Void, GetStockIbexSanUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    var canceled: Bool = false
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetStockIbexSanUseCaseOkOutput, StringErrorOutput> {
        let stocksManager = provider.getBsanStocksManager()
        let response = try stocksManager.getStocksQuoteIBEXSAN()
        if response.isSuccess(), let responseData = try response.getResponseData() {
            return UseCaseResponse.ok(GetStockIbexSanUseCaseOkOutput(stockList: responseData))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(StringErrorOutput(errorDescription))
    }
}

struct GetStockIbexSanUseCaseOkOutput {
    let stockIbex: StockQuote?
    let stockSan: StockQuote?
    
    init(stockList: StockQuotesListDTO) {
        var stockIbex: StockQuote?
        var stockSan: StockQuote?
        for stockDto in stockList.stockQuoteDTOS ?? [] {
            if let ticker = stockDto.ticker {
                switch ticker {
                case SANLegacyLibrary.Constants.TICKER_IBEX:
                    stockIbex = StockQuote(stockDto)
                case SANLegacyLibrary.Constants.TICKER_SAN:
                    stockSan = StockQuote(stockDto)
                default:
                    break
                }
            }
        }
        self.stockIbex = stockIbex
        self.stockSan = stockSan
    }
}
