class StocksTradeOperativeCCVSelectorPresenter: TradeOperativeStepPresenter<StocksTradeOperativeCCVSelectorViewController, VoidNavigator, StocksTradeOperativeCCVSelectorPresenterProtocol> {
    var stockAccountList: StockAccountList?
    let sectionHeader = TableModelViewSection()

    override func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void, onError: @escaping (OperativeContainerDialog) -> Void) {
        guard let container = container else {
            return
        }
        let selected: SelectedTradingStockAccount = container.provideParameter()
        onSuccess(selected.stockAccount == nil)
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        switch stockTradeData.order {
        case .buy:
            view.styledTitle = stringLoader.getString("toolbar_title_buyStock")
        case .sell:
            view.styledTitle = stringLoader.getString("toolbar_title_saleStock")
        }
        
        guard let container = container else {
            fatalError()
        }
        
        let stockAccountList: StockAccountList = container.provideParameter()
        let sectionContent = TableModelViewSection()
        let sectionTitleHeader = TitledTableModelViewHeader()
        sectionTitleHeader.title = stringLoader.getString("buyStock_text_selectStockAccount")
        sectionContent.setHeader(modelViewHeader: sectionTitleHeader)
        sectionContent.items = stockAccountList.list.map { SelectableCCVViewModel($0, dependencies) }
        
        view.sections = [sectionHeader, sectionContent]
    }
}

extension StocksTradeOperativeCCVSelectorPresenter: StocksTradeOperativeCCVSelectorPresenterProtocol {
    func headerLoaded(model: StockBaseHeaderViewModel) {
        let headerCell = GenericHeaderViewModel(viewModel: model, viewType: StockBaseHeaderView.self, dependencies: dependencies)
        sectionHeader.items = [headerCell]
    }
    
    func selected(index: Int, ofSection section: Int) {
        guard let container = container, let modelView = view.itemsSectionContent()[index] as? SelectableCCVViewModel else {
            return
        }
        
        var selected: SelectedTradingStockAccount = container.provideParameter()
        selected.stockAccount = modelView.stockAccount
        container.saveParameter(parameter: selected)
        container.stepFinished(presenter: self)
    }
}
