class TradeOperativeStepPresenter<View, Navigator, Contract>: OperativeStepPresenter<View, Navigator, Contract> where View: BaseViewController<Contract> {
    
    lazy var stockTradeData: StockTradeData = {
        guard let container = container else {
            fatalError()
        }
        return container.provideParameter()
    }()
    
    override func loadViewData() {
        super.loadViewData()

        guard var tradeOperativeView = view as? TradeOperativeViewControllerProtocol else {
            fatalError()
        }
        
        let stock = stockTradeData.stock
        let timeManager = dependencies.timeManager
        
        let datePart = timeManager.toString(date: stock.priceDate, outputFormat: .MMM_d)?.uppercased() ?? ""
        let timePart = timeManager.toString(date: stock.priceTime, outputFormat: .HHmm) ?? ""
        let priceDate = datePart + " - " + timePart
        let header = StockBaseHeaderViewModel(ticker: stock.ticker,
                                              priceDate: priceDate,
                                              priceVariation: stock.variationPrice?.getFormattedAmountUI(),
                                              variation: stock.variation,
                                              price: stock.price?.getFormattedAmountUI(4) ,
                                              compareZero: stock.variationCompare)
        
        tradeOperativeView.headerViewModel = header
    }
}
