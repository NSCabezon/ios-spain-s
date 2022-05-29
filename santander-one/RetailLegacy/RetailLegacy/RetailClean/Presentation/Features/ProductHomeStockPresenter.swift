import CoreFoundationLib

public enum StockAccountOrigin {
    case rvManaged
    case rvNotManaged
    case regular
}

class ProductHomeStockPresenter: ProductHomePresenter {
    lazy var usecase = LoadStockSuperUseCase(useCaseProvider: dependencies.useCaseProvider, useCaseHandler: dependencies.secondaryUseCaseHandler)

    deinit {
        usecase.cancelAll()
    }

    public init(header: ProductHomeHeaderPresenter & ProductProfileSeteable, detail: ProductHomeTransactionsPresenter & ProductProfileSeteable, sessionManager: CoreSessionManager, dependencies: PresentationComponent, navigator: ProductHomeNavigatorProtocol, origin: StockAccountOrigin = .regular) {
        super.init(header: header, detail: detail, sessionManager: sessionManager, dependencies: dependencies, navigator: navigator)

        let input = GetAllStockAccountsUseCaseInput(firstListOrigin: origin)
        UseCaseWrapper(with: dependencies.useCaseProvider.getAllStockAccountsUseCase(input: input), useCaseHandler: dependencies.useCaseHandler, errorHandler: nil, onSuccess: { [weak self]  result in
            guard let strongSelf = self else {
                return
            }
            strongSelf.getAllStockAccountsSuccess(result: result)
        })
    }

    override var productProfile: ProductProfile? {
        get {
            return super.productProfile
        }
        set {
            if let stockProfile = newValue as? StockProfile {
                stockProfile.superUsecase = usecase
                usecase.delegate = stockProfile
            }
            super.productProfile = newValue
        }
    }

    // MARK: - Private

    private func getAllStockAccountsSuccess(result: GetAllStockAccountsUseCaseOkOutput) {
        let stockAccounts = result.stockAccountList.get(ordered: true, visibles: true)
        var selectedIndex = 0
        if let selectedAccount = self.selectedProduct as? StockAccount {
            if let filteredStockAccountIndex = stockAccounts.firstIndex(where: {$0 == selectedAccount}) {
                selectedIndex = filteredStockAccountIndex
            }
        }

        self.usecase.getStocks(stockAccounts: stockAccounts, first: selectedIndex)
    }

}
