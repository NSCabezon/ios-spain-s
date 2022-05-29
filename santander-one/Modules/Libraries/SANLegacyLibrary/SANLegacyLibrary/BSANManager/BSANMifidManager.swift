public protocol BSANMifidManager {
    func getMifidIndicator(contractDTO: ContractDTO) throws -> BSANResponse<MifidIndicatorDTO>
    func getMifidClauses(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, tradedSharesCount: String, transferMode: String) throws -> BSANResponse<MifidDTO>
    func getCounterValueDetail(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO) throws -> BSANResponse<RMVDetailDTO>
}
