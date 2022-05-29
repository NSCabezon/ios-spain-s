import CoreDomain
import SANLegacyLibrary
import CoreFoundationLib

class GetRVNotManagedStockAccountsUseCase: UseCase<Void, GetRVNotManagedStockAccountsUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    var canceled: Bool = false
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetRVNotManagedStockAccountsUseCaseOkOutput, StringErrorOutput> {
        let stocksManager = provider.getBsanPortfoliosPBManager()
        let response = try stocksManager.getRVNotManagedStockAccountList()
        if response.isSuccess(), let responseData = try response.getResponseData() {
            let stockAccountList = StockAccountList.create(responseData, stockAccountType: .RVNotManaged)
            return UseCaseResponse.ok(GetRVNotManagedStockAccountsUseCaseOkOutput(stockAccountList: stockAccountList))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(StringErrorOutput(errorDescription))
    }
}

struct GetRVNotManagedStockAccountsUseCaseOkOutput {
    let stockAccountList: StockAccountList
}

extension GetRVNotManagedStockAccountsUseCase: Cancelable {
    func cancel() {
        canceled = true
    }
}
