import CoreDomain
import SANLegacyLibrary
import CoreFoundationLib

class GetRVManagedStockAccountsUseCase: UseCase<Void, GetRVManagedStockAccountsUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    var canceled: Bool = false
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetRVManagedStockAccountsUseCaseOkOutput, StringErrorOutput> {
        let stocksManager = provider.getBsanPortfoliosPBManager()
        let response = try stocksManager.getRVManagedStockAccountList()
        if response.isSuccess(), let responseData = try response.getResponseData() {
            let stockAccountList = StockAccountList.create(responseData, stockAccountType: .RVManaged)
            return UseCaseResponse.ok(GetRVManagedStockAccountsUseCaseOkOutput(stockAccountList: stockAccountList))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(StringErrorOutput(errorDescription))
    }
}

struct GetRVManagedStockAccountsUseCaseOkOutput {
    let stockAccountList: StockAccountList
}

extension GetRVManagedStockAccountsUseCase: Cancelable {
    func cancel() {
        canceled = true
    }
}
