class StocksMifid2StepPresenter: Mifid2StepPresenter {
     override func validate(completion: @escaping (Mifid2Response) -> Void) {
        guard let container = container else {
            return
        }
        
        let selectedStockAccount: SelectedTradingStockAccount = container.provideParameter()
        if let stockAccount = selectedStockAccount.stockAccount {
            let input = StocksMifid2IndicatorsUseCaseInput(mifidOperative: container.mifidOperative,
                                                           product: stockAccount)
            let useCase = useCaseProvider.stocksMifid2IndicatorsUseCase(input: input)
            UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { result in
                completion(.success(response: result))
            }, onGenericErrorType: { (error)  in
                completion(.error(response: error))
            })
        }
    }
}

class BuyStocksMifid2StepPresenter: StocksMifid2StepPresenter {

    // MARK: - Tracking

    override var screenId: String? {
        return TrackerPagePrivate.StocksBuyMifid().page
    }

}

class SellStocksMifid2StepPresenter: StocksMifid2StepPresenter {

    // MARK: - Tracking

    override var screenId: String? {
        return TrackerPagePrivate.StocksSellMidif().page
    }

}
