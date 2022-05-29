protocol StocksTradeLauncher: class {
    var dependencies: PresentationComponent { get }
    var errorHandler: GenericPresenterErrorHandler { get }
    var operativesNavigator: OperativesNavigatorProtocol { get }
    
    func launch(forStock stock: StockBase, in stockAccount: StockAccount?, tradeType: StocksTradeOrder, withDelegate delegate: ProductLauncherPresentationDelegate)
}

extension StocksTradeLauncher {
    func launch(forStock stock: StockBase, in stockAccount: StockAccount?, tradeType: StocksTradeOrder, withDelegate delegate: ProductLauncherPresentationDelegate) {
        delegate.startLoading()
        let input = SetupStocksTradeUseCaseInput(order: tradeType, stockAccount: stockAccount, stock: stock)
        let useCase = self.dependencies.useCaseProvider.setupStocksTradeUseCase(input: input)
        let dependencies = self.dependencies
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] result in
            let operative = StocksTradeOperative(tradeType: tradeType, dependencies: dependencies)
            let operativeData = StockTradeData(stock: stock, order: tradeType)
            let selectedStockAccount = SelectedTradingStockAccount(stockAccount: stockAccount)
            var parameters: [OperativeParameter] = [result.operativeConfig, operativeData, selectedStockAccount]
            if let selectableAccounts = result.stockAccountList {
                parameters.append(selectableAccounts)
            }
            delegate.endLoading(completion: {
                self?.operativesNavigator.goToOperative(operative, withParameters: parameters, dependencies: dependencies)
            })
        })
    }
}
