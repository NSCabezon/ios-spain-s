import SANLegacyLibrary
import CoreDomain

struct MockBSANStocksManager: BSANStocksManager {
    func getStocks(stockAccountDTO: StockAccountDTO, pagination: PaginationDTO?) throws -> BSANResponse<StockListDTO> {
        fatalError()
    }
    
    func getAllStocks(stockAccountDTO: StockAccountDTO) throws -> BSANResponse<StockListDTO> {
        fatalError()
    }
    
    func getStocksQuotes(searchString: String, pagination: PaginationDTO?) throws -> BSANResponse<StockQuotesListDTO> {
        fatalError()
    }
    
    func getQuoteDetail(stockQuoteDTO: StockQuoteDTO) throws -> BSANResponse<StockQuoteDetailDTO> {
        fatalError()
    }
    
    func getOrdenes(stockAccountDTO: StockAccountDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<OrderListDTO> {
        fatalError()
    }
    
    func deleteStockOrders() throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func getOrderDetail(order: OrderDTO, stockAccountDTO: StockAccountDTO) throws -> BSANResponse<OrderDetailDTO?> {
        fatalError()
    }
    
    func removeOrderDetail(order: OrderDTO, stockAccountDTO: StockAccountDTO) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func getStocksQuoteIBEXSAN() throws -> BSANResponse<StockQuotesListDTO> {
        fatalError()
    }
    
    func setCancellationOrder(orderDTO: OrderDTO, signatureDTO: SignatureDTO, stockAccountDTO: StockAccountDTO) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func validateBuyStockLimited(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockLimitedOperationInput: StockLimitedOperationInput) throws -> BSANResponse<StockDataBuySellDTO> {
        fatalError()
    }
    
    func validateBuyStockTypeOrder(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockTypeOrderOperationInput: StockTypeOrderOperationInput) throws -> BSANResponse<StockDataBuySellDTO> {
        fatalError()
    }
    
    func confirmBuyStockLimited(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockLimitedOperationInput: StockLimitedOperationInput, signatureDTO: SignatureDTO) throws -> BSANResponse<StockOperationDataConfirmDTO> {
        fatalError()
    }
    
    func confirmBuyStockTypeOrder(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockTypeOrderOperationInput: StockTypeOrderOperationInput, signatureDTO: SignatureDTO) throws -> BSANResponse<StockOperationDataConfirmDTO> {
        fatalError()
    }
    
    func validateSellStockLimited(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockLimitedOperationInput: StockLimitedOperationInput) throws -> BSANResponse<StockDataBuySellDTO> {
        fatalError()
    }
    
    func validateSellStockTypeOrder(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockTypeOrderOperationInput: StockTypeOrderOperationInput) throws -> BSANResponse<StockDataBuySellDTO> {
        fatalError()
    }
    
    func confirmSellStockLimited(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockLimitedOperationInput: StockLimitedOperationInput, signatureDTO: SignatureDTO) throws -> BSANResponse<StockOperationDataConfirmDTO> {
        fatalError()
    }
    
    func confirmSellStockTypeOrder(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockTypeOrderOperationInput: StockTypeOrderOperationInput, signatureDTO: SignatureDTO) throws -> BSANResponse<StockOperationDataConfirmDTO> {
        fatalError()
    }
}
