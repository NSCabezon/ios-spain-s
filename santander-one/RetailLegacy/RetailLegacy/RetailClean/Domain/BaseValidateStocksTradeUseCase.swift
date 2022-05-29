import CoreFoundationLib
import SANLegacyLibrary
import Foundation

protocol ValidateStocksTradeUseCaseOkOutputProtocol {
    init(data: StockDataBuySellDTO, account: Account?)
}

class BaseValidateStocksTradeUseCase<OkOutput: ValidateStocksTradeUseCaseOkOutputProtocol, ErrorOutput: StringErrorOutput>: UseCase<ValidateStocksTradeUseCaseInput, OkOutput, ErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(bsanManagerProvider: BSANManagersProvider) {
        self.provider = bsanManagerProvider
    }
    
    override func executeUseCase(requestValues: ValidateStocksTradeUseCaseInput) throws -> UseCaseResponse<OkOutput, ErrorOutput> {
        var account: Account?
        
        let possibleResponse: BSANResponse<StockDataBuySellDTO>?
        switch requestValues.orderType {
        case .toMarket,
             .byBest:
            possibleResponse = try validateStock(with: requestValues)
        case .byLimitation:
            possibleResponse = try validateStockLimited(with: requestValues)
        }
        
        guard let response = possibleResponse else {
            return UseCaseResponse.error(error(with: nil))
        }
        
        guard response.isSuccess(), let responseData = try response.getResponseData(), let linkedAccountDesc = try response.getResponseData()?.linkedAccountDescription else {
            return UseCaseResponse.error(error(with: try response.getErrorMessage()))
        }
        
        let accountResponse = try getLinkedAccount(provider: provider, ibanDTO: IBANDTO(ibanString: linkedAccountDesc))
        if accountResponse.isSuccess(), let accountDTO = try accountResponse.getResponseData() {
            account = Account.create(accountDTO)
        }
        
        return UseCaseResponse.ok(OkOutput(data: responseData, account: account))
    }
    
    func error(with errorString: String?) -> ErrorOutput {
        fatalError()
    }
    
    private func validateStockLimited(with requestValues: ValidateStocksTradeUseCaseInput) throws -> BSANResponse<StockDataBuySellDTO>? {
        let stockAccountDTO = requestValues.stockAccount.stockAccountDTO
        let stockQuoteDTO = requestValues.stock.quoteDto
        let configuration = requestValues.configuration
        guard case .byLimitation(let stringAmount) = requestValues.orderType else {
            return nil
        }
        
        guard case .success(let value) = Decimal.getAmountParserResult(value: stringAmount) else {
            return nil
        }
        
        let amount = Amount.createWith(value: value)
        
        let input = StockLimitedOperationInput(maxExchange: amount.amountDTO, tradesShare: configuration.numberOfTitlesValue, limitedDate: configuration.validityDate)
        
        switch requestValues.order {
        case .buy:
            return try provider.getBsanStocksManager().validateBuyStockLimited(stockAccountDTO: stockAccountDTO, stockQuoteDTO: stockQuoteDTO, stockLimitedOperationInput: input)
        case .sell:
            return try provider.getBsanStocksManager().validateSellStockLimited(stockAccountDTO: stockAccountDTO, stockQuoteDTO: stockQuoteDTO, stockLimitedOperationInput: input)
        }
    }
    
    private func validateStock(with requestValues: ValidateStocksTradeUseCaseInput) throws -> BSANResponse<StockDataBuySellDTO>? {
        let stockAccountDTO = requestValues.stockAccount.stockAccountDTO
        let stockQuoteDTO = requestValues.stock.quoteDto
        let orderType = requestValues.orderType
        let configuration = requestValues.configuration
        
        let input = StockTypeOrderOperationInput(stockTradingType: orderType.dto, tradesShare: configuration.numberOfTitlesValue, limitedDate: configuration.validityDate)
        
        switch requestValues.order {
        case .buy:
            return try provider.getBsanStocksManager().validateBuyStockTypeOrder(stockAccountDTO: stockAccountDTO, stockQuoteDTO: stockQuoteDTO, stockTypeOrderOperationInput: input)
        case .sell:
            return try provider.getBsanStocksManager().validateSellStockTypeOrder(stockAccountDTO: stockAccountDTO, stockQuoteDTO: stockQuoteDTO, stockTypeOrderOperationInput: input)
        }
    }
}

struct ValidateStocksTradeUseCaseInput {
    let stockAccount: StockAccount
    let order: StocksTradeOrder
    let orderType: StockTradeOrderType
    let configuration: OrderTitlesAndDateConfiguration
    let stock: StockBase
}

extension BaseValidateStocksTradeUseCase: AssociatedAccountRetriever {}
