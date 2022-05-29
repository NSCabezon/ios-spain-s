import CoreDomain

public protocol BSANStocksManager {
    func getStocks(stockAccountDTO: StockAccountDTO, pagination: PaginationDTO?) throws -> BSANResponse<StockListDTO>
    func getAllStocks(stockAccountDTO: StockAccountDTO) throws -> BSANResponse<StockListDTO>
    func getStocksQuotes(searchString: String, pagination: PaginationDTO?) throws -> BSANResponse<StockQuotesListDTO>
    func getQuoteDetail(stockQuoteDTO: StockQuoteDTO) throws -> BSANResponse<StockQuoteDetailDTO>
    func getOrdenes(stockAccountDTO: StockAccountDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<OrderListDTO>
    func deleteStockOrders() throws -> BSANResponse<Void>
    func getOrderDetail(order: OrderDTO, stockAccountDTO: StockAccountDTO) throws -> BSANResponse<OrderDetailDTO?>
    func removeOrderDetail(order: OrderDTO, stockAccountDTO: StockAccountDTO) throws -> BSANResponse<Void>
    func getStocksQuoteIBEXSAN() throws -> BSANResponse<StockQuotesListDTO>
    func setCancellationOrder(orderDTO: OrderDTO, signatureDTO: SignatureDTO, stockAccountDTO: StockAccountDTO) throws -> BSANResponse<Void>
    func validateBuyStockLimited(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockLimitedOperationInput: StockLimitedOperationInput) throws -> BSANResponse<StockDataBuySellDTO>
    func validateBuyStockTypeOrder(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockTypeOrderOperationInput: StockTypeOrderOperationInput) throws -> BSANResponse<StockDataBuySellDTO>
    func confirmBuyStockLimited(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockLimitedOperationInput: StockLimitedOperationInput, signatureDTO: SignatureDTO) throws -> BSANResponse<StockOperationDataConfirmDTO>
    func confirmBuyStockTypeOrder(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockTypeOrderOperationInput: StockTypeOrderOperationInput, signatureDTO: SignatureDTO) throws -> BSANResponse<StockOperationDataConfirmDTO>
    func validateSellStockLimited(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockLimitedOperationInput: StockLimitedOperationInput) throws -> BSANResponse<StockDataBuySellDTO>
    func validateSellStockTypeOrder(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockTypeOrderOperationInput: StockTypeOrderOperationInput) throws -> BSANResponse<StockDataBuySellDTO>
    func confirmSellStockLimited(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockLimitedOperationInput: StockLimitedOperationInput, signatureDTO: SignatureDTO) throws -> BSANResponse<StockOperationDataConfirmDTO>
    func confirmSellStockTypeOrder(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, stockTypeOrderOperationInput: StockTypeOrderOperationInput, signatureDTO: SignatureDTO) throws -> BSANResponse<StockOperationDataConfirmDTO>
}

