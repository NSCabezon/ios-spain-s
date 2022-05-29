import SANLegacyLibrary
import CoreDomain

struct MockBSANPortfoliosPBManager: BSANPortfoliosPBManager {
    func getPortfoliosNotManaged() throws -> BSANResponse<[PortfolioDTO]> {
        fatalError()
    }
    
    func getPortfoliosManaged() throws -> BSANResponse<[PortfolioDTO]> {
        fatalError()
    }
    
    func getRVPortfoliosNotManaged() throws -> BSANResponse<[PortfolioDTO]> {
        fatalError()
    }
    
    func getRVPortfoliosManaged() throws -> BSANResponse<[PortfolioDTO]> {
        fatalError()
    }
    
    func getRVManagedStockAccountList() throws -> BSANResponse<[StockAccountDTO]> {
        fatalError()
    }
    
    func getRVNotManagedStockAccountList() throws -> BSANResponse<[StockAccountDTO]> {
        fatalError()
    }
    
    func loadPortfoliosPb() throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func loadPortfoliosSelect() throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func resetPortfolios() {
        fatalError()
    }
    
    func loadVariableIncomePortfolioPb() throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func loadVariableIncomePortfolioSelect() throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func deletePortfoliosProducts() throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func getPortfolioProducts(portfolioPBDTO: PortfolioDTO) throws -> BSANResponse<[PortfolioProductDTO]> {
        fatalError()
    }
    
    func getHolderDetail(portfolioPBDTO: PortfolioDTO) throws -> BSANResponse<[HolderDTO]> {
        fatalError()
    }
    
    func getPortfolioProductTransactionDetail(transactionDTO: PortfolioTransactionDTO) throws -> BSANResponse<PortfolioTransactionDetailDTO> {
        fatalError()
    }
    
    func getPortfolioProductTransactions(portfolioProductPBDTO: PortfolioProductDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<PortfolioTransactionsListDTO> {
        fatalError()
    }    
}
