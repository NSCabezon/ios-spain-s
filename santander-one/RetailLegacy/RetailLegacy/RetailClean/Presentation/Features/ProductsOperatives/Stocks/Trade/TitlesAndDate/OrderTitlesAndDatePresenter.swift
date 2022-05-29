import Foundation

struct OrderTitlesAndDateConfiguration {
    static var empty: OrderTitlesAndDateConfiguration {
        return OrderTitlesAndDateConfiguration(numberOfTitles: "", validityDate: nil)
    }
    var numberOfTitles: String
    var numberOfTitlesValue: String {
        return numberOfTitles.replace(".", "")
    }
    var validityDate: Date?
}

extension OrderTitlesAndDateConfiguration: OperativeParameter {}

class OrderTitlesAndDatePresenter: TradeOperativeStepPresenter<OrderTitlesAndDateViewController, VoidNavigator, OrderTitlesAndDatePresenterProtocol> {
    
    let sectionHeader = TableModelViewSection()

    // MARK: - Tracking

    override var screenId: String? {
        switch stockTradeData.order {
        case .buy:
            return TrackerPagePrivate.StocksBuyNumberTitles().page
        case .sell:
            return TrackerPagePrivate.StocksSellNumberTitles().page
        }
    }

    // MARK: -

    private var configuration: OrderTitlesAndDateConfiguration = .empty
    
    private var configurationSections = [TableModelViewSection]()

    private var validContainer: OperativeContainer {
        guard let container = container as? OperativeContainer else {
            fatalError()
        }
        return container
    }
    
    private lazy var selectedCCV: SelectedTradingStockAccount = {
        return validContainer.provideParameter()
    }()
    
    private lazy var orderType: StockTradeOrderType = {
        return validContainer.provideParameter()
    }()
    
    enum ConfigurationItemIndex: Int {
        case numberOfTitles = 1
        case validityDate = 2
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        switch stockTradeData.order {
        case .buy:
            view.styledTitle = stringLoader.getString("toolbar_title_buyStock")
        case .sell:
            view.styledTitle = stringLoader.getString("toolbar_title_saleStock")
        }
        
        view.confirmButtonTitle = stringLoader.getString("generic_button_continue")
        
        updateSections()
        view.sections = configurationSections
    }
    
    private func updateSections() {
        let titlesSection = updateTitlesSection()
        let validityDateSection = updateValidityDateSection()
        
        configurationSections = [sectionHeader, titlesSection, validityDateSection]
    }
    
    private func updateTitlesSection() -> TableModelViewSection {
        if let titlesSection = configurationSections[safe: ConfigurationItemIndex.numberOfTitles.rawValue] {
            return titlesSection
        }
        let titlesSection = TableModelViewSection()
        
        let sectionHeader = TitledTableModelViewHeader()
        sectionHeader.title = stringLoader.getString("buySale_text_numberTitles")
        
        titlesSection.setHeader(modelViewHeader: sectionHeader)
        
        let titlesItem = FormatedTextFieldCellViewModel(stringLoader.getString("buySale_text_numberTitles"),
                                                        .numeric(12, 0),
                                                        dependencies, nextType: KeyboardTextFieldResponderOrder.none)
        
        titlesSection.add(item: titlesItem)
        
        return titlesSection
    }
    
    private func updateValidityDateSection() -> TableModelViewSection {
        let dateSection = TableModelViewSection()
        
        let sectionHeader = TitledTableModelViewHeader()
        sectionHeader.title = stringLoader.getString("buySale_text_validityPeriod")
        
        dateSection.setHeader(modelViewHeader: sectionHeader)
        
        let dateItem = StockOrderValidityDateItemViewModel(placeholder: stringLoader.getString("buySale_text_validityPeriod"),
                                                           date: configuration.validityDate,
                                                           textFieldStyle: TextFieldStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 16.0), textAlignment: .left),
                                                           privateComponent: dependencies)
        dateItem.lowerLimitDate = Date()
        
        let textItem = OperativeLabelTableModelView(title: stringLoader.getString("buySale_text_info"), style: LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14.0)), privateComponent: dependencies)
        
        dateItem.delegate = self
        dateSection.add(item: dateItem)
        dateSection.add(item: textItem)
        
        return dateSection
    }
}

extension OrderTitlesAndDatePresenter: OrderTitlesAndDatePresenterProtocol {
    func headerLoaded(model: StockBaseHeaderViewModel) {
        let headerCell = GenericHeaderViewModel(viewModel: model, viewType: StockBaseHeaderView.self, dependencies: dependencies)
        sectionHeader.items = [headerCell]
    }    
    
    func setDate(date: Date, atSection section: Int) {
        guard section == ConfigurationItemIndex.validityDate.rawValue else {
            return
        }
        guard let dateItem = configurationSections[section].items.first as? StockOrderValidityDateItemViewModel else {
            return
        }
        configuration.validityDate = date
        dateItem.date = date
    }
    
    func confirmButtonTouched() {
        guard validateConfiguration() else {
            return
        }
        container?.saveParameter(parameter: configuration)
        
        guard let stockAccount = selectedCCV.stockAccount else {
            return
        }
        
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: view)
        let input = ValidateStocksTradeUseCaseInput(stockAccount: stockAccount,
                                                    order: stockTradeData.order,
                                                    orderType: orderType,
                                                    configuration: configuration,
                                                    stock: stockTradeData.stock)
        let useCase = useCaseProvider.preValidateStocksTradeUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] response in
            guard let thisPresenter = self else {
                return
            }
            let preValidateData = StocksTradePreValidateData(linkedAccountBalance: response.linkedAccountBalance,
                                                             limitDate: response.limitDate,
                                                             owner: response.holder,
                                                             linkedAccountDescription: response.linkedAccountDescription,
                                                             account: response.account)
            thisPresenter.container?.saveParameter(parameter: preValidateData)
            thisPresenter.hideLoading(completion: {
                thisPresenter.container?.stepFinished(presenter: thisPresenter)
            })
        }, onError: { [weak self] error in
            guard let thisPresenter = self else {
                return
            }
            thisPresenter.hideLoading(completion: {
                thisPresenter.showError(keyDesc: error?.getErrorDesc())
            })
        })
    }
    
    private func validateConfiguration() -> Bool {
        let titlesViewModel = configurationSections[ConfigurationItemIndex.numberOfTitles.rawValue].items.first as? FormatedTextFieldCellViewModel
        
        configuration.numberOfTitles = titlesViewModel?.value ?? ""
        
        guard let titles = Int(configuration.numberOfTitlesValue) else {
            showError(keyTitle: "generic_alert_title_errorData", keyDesc: "buySale_allert_insertNtitles")
            return false
        }
        
        guard titles > 0 else {
            showError(keyTitle: "generic_alert_title_errorData", keyDesc: "buySale_allert_nTitlesMore0")
            return false
        }
        
        return true
    }
}

extension OrderTitlesAndDatePresenter: StockOrderValidityDateItemViewModelDelegate {
    func dateCleared() {
        configuration.validityDate = nil
    }
}
