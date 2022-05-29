import SANLegacyLibrary
import CoreFoundationLib
import Foundation

class ConfirmStocksTradeUseCase: ConfirmUseCase<ConfirmStocksTradeUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmStocksTradeUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorSignatureErrorOutput> {
        let possibleResponse: BSANResponse<StockOperationDataConfirmDTO>?
        switch requestValues.orderType {
        case .toMarket,
             .byBest:
            possibleResponse = try confirmStock(with: requestValues)
        case .byLimitation:
            possibleResponse = try confirmStockLimited(with: requestValues)
        }
        
        guard let response = possibleResponse else {
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
        }
        
        let signatureResult = try getSignatureResult(response)
        guard response.isSuccess(), case .ok = signatureResult else {
            let errorCode = try response.getErrorCode()
            let errorDescription = try response.getErrorMessage()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureResult, errorCode))
        }
        
        return UseCaseResponse.ok()
    }
    
    private func confirmStockLimited(with requestValues: ConfirmStocksTradeUseCaseInput) throws -> BSANResponse<StockOperationDataConfirmDTO>? {
        let stockAccountDTO = requestValues.stockAccount.stockAccountDTO
        let stockQuoteDTO = requestValues.stock.quoteDto
        let configuration = requestValues.configuration
        let signatureDTO = requestValues.signature.dto
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
            return try provider.getBsanStocksManager().confirmBuyStockLimited(stockAccountDTO: stockAccountDTO, stockQuoteDTO: stockQuoteDTO, stockLimitedOperationInput: input, signatureDTO: signatureDTO)
        case .sell:
            return try provider.getBsanStocksManager().confirmSellStockLimited(stockAccountDTO: stockAccountDTO, stockQuoteDTO: stockQuoteDTO, stockLimitedOperationInput: input, signatureDTO: signatureDTO)
        }
    }
    
    private func confirmStock(with requestValues: ConfirmStocksTradeUseCaseInput) throws -> BSANResponse<StockOperationDataConfirmDTO>? {
        let stockAccountDTO = requestValues.stockAccount.stockAccountDTO
        let stockQuoteDTO = requestValues.stock.quoteDto
        let orderType = requestValues.orderType
        let configuration = requestValues.configuration
        let signatureDTO = requestValues.signature.dto
        
        let input = StockTypeOrderOperationInput(stockTradingType: orderType.dto, tradesShare: configuration.numberOfTitlesValue, limitedDate: configuration.validityDate)
        
        switch requestValues.order {
        case .buy:
            return try provider.getBsanStocksManager().confirmBuyStockTypeOrder(stockAccountDTO: stockAccountDTO, stockQuoteDTO: stockQuoteDTO, stockTypeOrderOperationInput: input, signatureDTO: signatureDTO)
            
        case .sell:
            return try provider.getBsanStocksManager().confirmSellStockTypeOrder(stockAccountDTO: stockAccountDTO, stockQuoteDTO: stockQuoteDTO, stockTypeOrderOperationInput: input, signatureDTO: signatureDTO)
        }
    }
}

struct ConfirmStocksTradeUseCaseInput {
    let stockAccount: StockAccount
    let order: StocksTradeOrder
    let orderType: StockTradeOrderType
    let configuration: OrderTitlesAndDateConfiguration
    let stock: StockBase
    let signature: Signature
}
