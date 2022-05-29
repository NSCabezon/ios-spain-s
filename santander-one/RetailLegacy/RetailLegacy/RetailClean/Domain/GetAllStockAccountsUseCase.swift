import SANLegacyLibrary
import CoreFoundationLib
import CoreDomain

class GetAllStockAccountsUseCase: UseCase<GetAllStockAccountsUseCaseInput, GetAllStockAccountsUseCaseOkOutput, StringErrorOutput> {
    
    private let appRepository: AppRepository
    private let provider: BSANManagersProvider
    private var accountDescriptorRepository: AccountDescriptorRepository
    private let appConfigRepository: AppConfigRepository
    var canceled: Bool = false
    
    init(provider: BSANManagersProvider, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository, appConfigRepository: AppConfigRepository) {
        self.appRepository = appRepository
        self.provider = provider
        self.accountDescriptorRepository = accountDescriptorRepository
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: GetAllStockAccountsUseCaseInput) throws -> UseCaseResponse<GetAllStockAccountsUseCaseOkOutput, StringErrorOutput> {
        
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        guard let globalPositionWrapper = merger.globalPositionWrapper else {
            return UseCaseResponse.error(GetPGProductsUseCaseErrorOutput(nil))
        }
        let stockAccountsCCV = globalPositionWrapper.stockAccounts.list
        let stockAccountsRVM = globalPositionWrapper.managedRVStockAccounts.list
        let stockAccountsRVMNot = globalPositionWrapper.notManagedRVStockAccounts.list
        let outputList = StockAccountList.create([], stockAccountType: nil)
        switch requestValues.firstListOrigin {
        case .regular:
            outputList.list.append(contentsOf: stockAccountsCCV)
            outputList.list.append(contentsOf: stockAccountsRVM)
            outputList.list.append(contentsOf: stockAccountsRVMNot)
        case .rvManaged:
            outputList.list.append(contentsOf: stockAccountsRVM)
            outputList.list.append(contentsOf: stockAccountsCCV)
            outputList.list.append(contentsOf: stockAccountsRVMNot)
        case .rvNotManaged:
            outputList.list.append(contentsOf: stockAccountsRVMNot)
            outputList.list.append(contentsOf: stockAccountsCCV)
            outputList.list.append(contentsOf: stockAccountsRVM)
        }
        return UseCaseResponse.ok(GetAllStockAccountsUseCaseOkOutput(stockAccountList: outputList.unique()))
    }
}

struct GetAllStockAccountsUseCaseInput {
    let firstListOrigin: StockAccountOrigin
}

struct GetAllStockAccountsUseCaseOkOutput {
    let stockAccountList: StockAccountList
}

extension GetAllStockAccountsUseCase: Cancelable {
    func cancel() {
        canceled = true
    }
}
