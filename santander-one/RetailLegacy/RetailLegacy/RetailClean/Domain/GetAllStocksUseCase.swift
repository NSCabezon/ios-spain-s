import CoreDomain
import SANLegacyLibrary
import CoreFoundationLib

class GetAllStocksUseCase: UseCase<Void, GetAllStocksUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    var canceled: Bool = false
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetAllStocksUseCaseOkOutput, StringErrorOutput> {
        
        let stockAccountsList = StockAccountList.create([], stockAccountType: nil)
        var outputList = [StockDTO]()
        do {
            try stockAccountsList.list.append(contentsOf: callCCVStockAccounts().map({StockAccount(dto: $0)}))
            try stockAccountsList.list.append(contentsOf: callRVManagedStockAccounts().map({StockAccount(dto: $0)}))
            try stockAccountsList.list.append(contentsOf: callRVNotManagedStockAccounts().map({StockAccount(dto: $0)}))
            
            for stockAccount in stockAccountsList.unique().list {
                outputList.append(contentsOf: getAllStocksFrom(stockAccountDTO: stockAccount.stockAccountDTO))
            }
            
            return UseCaseResponse.ok(GetAllStocksUseCaseOkOutput(stocksList: outputList.map({Stock(dto: $0)})))
            
        } catch let e {
            return UseCaseResponse.error(StringErrorOutput(e.localizedDescription))
        }
    }
    
    private func callCCVStockAccounts() throws -> [StockAccountDTO] {
        let gPositionDTO = try checkRepositoryResponse(provider.getBsanPGManager().getGlobalPosition())!
        let output = StockAccountList.create(gPositionDTO.stockAccounts ?? [], stockAccountType: StockAccountType.CCV)
        return output.unique().list.map({$0.stockAccountDTO})
    }
    
    private func callRVNotManagedStockAccounts() throws -> [StockAccountDTO] {
        let stocksManager = provider.getBsanPortfoliosPBManager()
        let response = try stocksManager.getRVNotManagedStockAccountList()
        if response.isSuccess(), let responseData = try response.getResponseData() {
            let output = StockAccountList.create(responseData, stockAccountType: StockAccountType.RVNotManaged)
            return output.unique().list.map({$0.stockAccountDTO})
        }
        
        return []
    }
    
    private func callRVManagedStockAccounts() throws -> [StockAccountDTO] {
        let stocksManager = provider.getBsanPortfoliosPBManager()
        let response = try stocksManager.getRVManagedStockAccountList()
        if response.isSuccess(), let responseData = try response.getResponseData() {
            let output = StockAccountList.create(responseData, stockAccountType: StockAccountType.RVManaged)
            return output.unique().list.map({$0.stockAccountDTO})
        }
        
        return []
    }
    
    private func getAllStocksFrom(stockAccountDTO: StockAccountDTO) -> [StockDTO] {
        let stocksManager = provider.getBsanStocksManager()
        do {
            let response = try stocksManager.getAllStocks(stockAccountDTO: stockAccountDTO)
            if response.isSuccess(), let data = try response.getResponseData(), let list = data.stockListDTO, !canceled {
                return list
            }
            
            return []
        } catch _ {
            return []
        }
    }
}

struct GetAllStocksUseCaseOkOutput {
    let stocksList: [Stock]
}
