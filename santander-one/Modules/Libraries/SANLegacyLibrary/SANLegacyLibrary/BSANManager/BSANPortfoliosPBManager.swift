import CoreDomain

public protocol BSANPortfoliosPBManager {
    func getPortfoliosNotManaged() throws -> BSANResponse<[PortfolioDTO]>
    func getPortfoliosManaged() throws -> BSANResponse<[PortfolioDTO]>
    func getRVPortfoliosNotManaged() throws -> BSANResponse<[PortfolioDTO]>
    func getRVPortfoliosManaged() throws -> BSANResponse<[PortfolioDTO]>
    func getRVManagedStockAccountList() throws -> BSANResponse<[StockAccountDTO]>
    func getRVNotManagedStockAccountList() throws -> BSANResponse<[StockAccountDTO]>
    func loadPortfoliosPb() throws -> BSANResponse<Void>
    func loadPortfoliosSelect() throws -> BSANResponse<Void>
    func resetPortfolios()
    func loadVariableIncomePortfolioPb() throws -> BSANResponse<Void>
    func loadVariableIncomePortfolioSelect() throws -> BSANResponse<Void>
    
    @discardableResult
    func deletePortfoliosProducts() throws -> BSANResponse<Void>
    func getPortfolioProducts(portfolioPBDTO: PortfolioDTO) throws -> BSANResponse<[PortfolioProductDTO]>
    func getHolderDetail(portfolioPBDTO: PortfolioDTO) throws -> BSANResponse<[HolderDTO]>
    func getPortfolioProductTransactionDetail(transactionDTO: PortfolioTransactionDTO) throws -> BSANResponse<PortfolioTransactionDetailDTO>
    func getPortfolioProductTransactions(portfolioProductPBDTO: PortfolioProductDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<PortfolioTransactionsListDTO>
}
