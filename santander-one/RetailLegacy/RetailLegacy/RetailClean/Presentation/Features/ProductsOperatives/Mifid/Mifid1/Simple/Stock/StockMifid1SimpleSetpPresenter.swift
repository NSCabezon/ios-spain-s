class StockMifid1SimpleSetpPresenter: Mifid1SimpleStepPresenter {
    override func validate(completion: @escaping (Mifid1SimpleResponse) -> Void) {
        
        guard let container = container else { return }
        
        let selectedStockAccount: SelectedTradingStockAccount = container.provideParameter()
        guard let stockAccount = selectedStockAccount.stockAccount else { return }
        let stockTradeData: StockTradeData = container.provideParameter()
        let configuration: OrderTitlesAndDateConfiguration = container.provideParameter()
        
        let params = StockMifidClausesParamenters(stockAccount: stockAccount,
                                                  stockTradeData: stockTradeData,
                                                  tradeType: stockTradeData.order,
                                                  configuration: configuration)
        
        let input = StocksMifid1UseCaseInput(data: params)
        let useCase = useCaseProvider.stocksMifid1UseCase(input: input)
        
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
            completion(.success(response: result))
        }, onGenericErrorType: { error in
            completion(.error(response: error))
        })
    }
}

class BuyStockMifid1SimpleSetpPresenter: StockMifid1SimpleSetpPresenter {

    // MARK: - Tracking

    override var screenId: String? {
        return TrackerPagePrivate.StocksBuyMifid().page
    }

}

class SellStockMifid1SimpleSetpPresenter: StockMifid1SimpleSetpPresenter {

    // MARK: - Tracking

    override var screenId: String? {
        return TrackerPagePrivate.StocksSellMidif().page
    }

}
