class StocksMifidAvisoryClausesPresenter: MifidAdvisoryClausesStepPresenter {
    override func validate(completion: @escaping (MifidAdvisoryClausesResponse) -> Void) {
        guard let container = container else {
            return
        }
        let ccvSelection: SelectedTradingStockAccount = container.provideParameter()
        guard let selectedCCV = ccvSelection.stockAccount else {
            return
        }
        
        let stockTradeData: StockTradeData = container.provideParameter()
        
        let configuration: OrderTitlesAndDateConfiguration = container.provideParameter()
        let parameters = StockMifidClausesParamenters(stockAccount: selectedCCV,
                                     stockTradeData: stockTradeData,
                                     tradeType: stockTradeData.order,
                                     configuration: configuration)
        let input = StocksMifidAdvicesUseCaseInput(data: parameters)
        let useCase = useCaseProvider.stocksMifidAdvicesUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
            completion(.success(state: result.state))
        }, onGenericErrorType: { error in
            completion(.error(response: error))
        })
    }
}

class BuyStocksMifidAvisoryClausesPresenter: StocksMifidAvisoryClausesPresenter {

    // MARK: - Tracking

    override var screenId: String? {
        return TrackerPagePrivate.StocksBuyMifid().page
    }

}

class SellStocksMifidAvisoryClausesPresenter: StocksMifidAvisoryClausesPresenter {

    // MARK: - Tracking

    override var screenId: String? {
        return TrackerPagePrivate.StocksSellMidif().page
    }

}
