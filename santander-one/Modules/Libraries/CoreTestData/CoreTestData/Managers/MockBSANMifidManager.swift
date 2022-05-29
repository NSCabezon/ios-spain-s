import SANLegacyLibrary

struct MockBSANMifidManager: BSANMifidManager {
    func getMifidIndicator(contractDTO: ContractDTO) throws -> BSANResponse<MifidIndicatorDTO> {
        fatalError()
    }
    
    func getMifidClauses(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO, tradedSharesCount: String, transferMode: String) throws -> BSANResponse<MifidDTO> {
        fatalError()
    }
    
    func getCounterValueDetail(stockAccountDTO: StockAccountDTO, stockQuoteDTO: StockQuoteDTO) throws -> BSANResponse<RMVDetailDTO> {
        fatalError()
    }
}
