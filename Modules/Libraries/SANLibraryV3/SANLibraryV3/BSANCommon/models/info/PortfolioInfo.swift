import Foundation

public class PortfolioInfo: Codable {

    public var portfolioProductsList: [String : [PortfolioProductDTO]] = [:]
    public var portfolioManagedList: [PortfolioDTO] = []
    public var portfolioNotManagedList: [PortfolioDTO] = []
    public var portfolioRVManagedList: [PortfolioDTO] = []
    public var portfolioRVNotManagedList: [PortfolioDTO] = []
    public var portfolioRVManagedStockAccountList: [StockAccountDTO] = []
    public var portfolioRVNotManagedStockAccountList: [StockAccountDTO] = []
    public var portfolioProductTransacions: [String : PortfolioTransactionsListDTO] = [:]
    
    public func removePortfolios(){
        portfolioProductsList = [String : [PortfolioProductDTO]]()
        portfolioManagedList = [PortfolioDTO]()
        portfolioNotManagedList = [PortfolioDTO]()
        portfolioRVManagedList = [PortfolioDTO]()
        portfolioRVNotManagedList = [PortfolioDTO]()
        portfolioRVManagedStockAccountList = [StockAccountDTO]()
        portfolioRVNotManagedStockAccountList = [StockAccountDTO]()
        portfolioProductTransacions = [String : PortfolioTransactionsListDTO]()
    }

    public func setPortfolioManagedList(_ portfolioManagedList: [PortfolioDTO]) -> PortfolioInfo {
        self.portfolioManagedList = portfolioManagedList
        return self
    }

    public func setPortfolioNotManagedList(_ portfolioNotManagedList: [PortfolioDTO]) -> PortfolioInfo {
        self.portfolioNotManagedList = portfolioNotManagedList
        return self
    }

    public func setPortfolioRVManagedList(_ portfolioRVManagedList: [PortfolioDTO]) -> PortfolioInfo {
        self.portfolioRVManagedList = portfolioRVManagedList
        return self
    }

    public func setPortfolioRVNotManagedList(_ portfolioRVNotManagedList: [PortfolioDTO]) -> PortfolioInfo {
        self.portfolioRVNotManagedList = portfolioRVNotManagedList
        return self
    }

    public func setPortfolioRVManagedStockAccountList(portfolioRVManagedStockAccountList: [StockAccountDTO]) -> PortfolioInfo {
        self.portfolioRVManagedStockAccountList = portfolioRVManagedStockAccountList
        return self
    }

    public func setPortfolioRVNotManagedStockAccountList(portfolioRVNotManagedStockAccountList: [StockAccountDTO]) -> PortfolioInfo {
        self.portfolioRVNotManagedStockAccountList = portfolioRVNotManagedStockAccountList
        return self
    }
    
    public func getRVManagedStockAccountList() -> [StockAccountDTO] {
        return self.portfolioRVManagedStockAccountList
    }
    
    public func getRVNotManagedStockAccountList() -> [StockAccountDTO] {
        return self.portfolioRVNotManagedStockAccountList
    }
    
    public func addPortfolioProductTransactionList(portfolioProductTransactionList: PortfolioTransactionsListDTO, contractId: String){
        var portfolioTransactionListToAdd = portfolioProductTransactionList.transactionDTOs ?? []
        var storedPortfolioTransactionList = portfolioProductTransacions[contractId]
        
        if let storedPortfolioTransactionList = storedPortfolioTransactionList{
            let storedList = storedPortfolioTransactionList.transactionDTOs
            
            if let oldContentToInsertInNew = storedList{
                for portfolioTransaction in oldContentToInsertInNew{
                    portfolioTransactionListToAdd.append(portfolioTransaction)
                }
            }
        }
        
        storedPortfolioTransactionList = PortfolioTransactionsListDTO(transactionDTOs: portfolioTransactionListToAdd, pagination: portfolioProductTransactionList.pagination)
        portfolioProductTransacions[contractId] = storedPortfolioTransactionList
    }
}
