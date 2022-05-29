//

import SANLegacyLibrary
import CoreFoundationLib

class GetStocksQuoteSearchUseCase: UseCase<GetStocksQuoteSearchUseCaseInput, GetStocksQuoteSearchUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    var canceled: Bool = false
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetStocksQuoteSearchUseCaseInput) throws -> UseCaseResponse<GetStocksQuoteSearchUseCaseOkOutput, StringErrorOutput> {
        let stocksManager = provider.getBsanStocksManager()
        let response = try stocksManager.getStocksQuotes(searchString: requestValues.searchTerms, pagination: requestValues.pagination?.dto)
        if response.isSuccess(), let responseData = try response.getResponseData() {
            let stockQuotes = responseData.stockQuoteDTOS?.map { StockQuote($0) } ?? []
            return UseCaseResponse.ok(GetStocksQuoteSearchUseCaseOkOutput(stockQuotes: stockQuotes, pagination: PaginationDO(dto: responseData.pagination)))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(StringErrorOutput(errorDescription))
    }
}

struct GetStocksQuoteSearchUseCaseInput {
    let searchTerms: String
    let pagination: PaginationDO?
}

struct GetStocksQuoteSearchUseCaseOkOutput {
    let stockQuotes: [StockQuote]
    let pagination: PaginationDO?
}
