import Foundation

class StocksTradeConfirmationPresenter: TradeOperativeStepPresenter<StocksTradeConfirmationViewController, DefaultMifidLauncherNavigator, StocksTradeConfirmationPresenterProtocol> {
    let sectionHeader = TableModelViewSection()

    // MARK: - Tracking

    override var screenId: String? {
        switch stockTradeData.order {
        case .buy:
            return TrackerPagePrivate.StocksBuyConfirmation().page
        case .sell:
            return TrackerPagePrivate.StocksSellConfirmation().page
        }
    }

    // MARK: -

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
    
    private lazy var titlesAndDate: OrderTitlesAndDateConfiguration = {
        return validContainer.provideParameter()
    }()
    
    private lazy var preValidateData: StocksTradePreValidateData = {
        return validContainer.provideParameter()
    }()
    
    override func loadViewData() {
        super.loadViewData()
        
        view.styledTitle = stringLoader.getString("genericToolbar_title_confirmation")        
        view.confirmButtonTitle = stringLoader.getString("generic_button_confirm")

        visualizeData(withLimitDate: preValidateData.limitDate, owner: preValidateData.owner, linkedAccount: preValidateData.linkedAccountDescription, linkedAccountAmount: preValidateData.linkedAccountBalance, account: preValidateData.account)
    }
    
    private func visualizeData(withLimitDate limitDate: Date?, owner: String?, linkedAccount: String?, linkedAccountAmount: Amount?, account: Account?) {
        guard let stockAccount = selectedCCV.stockAccount else {
            return
        }
        
        let stockAccountSection = TableModelViewSection()
        
        let stockAccountHeader = TitledTableModelViewHeader()
        stockAccountHeader.title = stringLoader.getString("confirmation_text_accountsStock")
        
        stockAccountSection.setHeader(modelViewHeader: stockAccountHeader)
        
        let stockAccountItem = StockTradeConfirmationCCVViewModel(stockAccount, dependencies)
        stockAccountSection.items = [stockAccountItem]
        
        let stockTradeSection = TableModelViewSection()
        
        let stockTradeHeader = TitledTableModelViewHeader()
        
        switch stockTradeData.order {
        case .buy:
            stockTradeHeader.title = stringLoader.getString("confirmation_item_buyStock")
        case .sell:
            stockTradeHeader.title = stringLoader.getString("confirmation_item_saleStock")
        }
        
        stockTradeSection.setHeader(modelViewHeader: stockTradeHeader)
        
        let orderTypeItem = SimpleConfirmationTableViewHeaderModel(stringLoader.getString("confirmation_item_kindOrder"),
                                                                   orderType.localizedTitle(with: stringLoader).text,
                                                                   false,
                                                                   dependencies)
        stockTradeSection.items.append(orderTypeItem)
        
        var simpleItems: [(title: LocalizedStylableText, value: String, color: ConfirmationTableViewItemModelColor)] = []
        
        if case .byLimitation(let price) = orderType, case .success(let value) = Decimal.getAmountParserResult(value: price) {
            let amount = Amount.createWith(value: value)
            let limitDateItem = (stringLoader.getString("confirmation_item_limit"), amount.getFormattedAmountUI(4), color: ConfirmationTableViewItemModelColor.green)
            simpleItems.append(limitDateItem)
        }
        
        let titlesItem = (stringLoader.getString("confirmation_item_numberTitles"), titlesAndDate.numberOfTitles, color: ConfirmationTableViewItemModelColor.normal)
    
        simpleItems.append(titlesItem)
        
        if let date = preValidateData.limitDate {
            let validityDateItem = (stringLoader.getString("confirmation_item_validityPeriod"), dependencies.timeManager.toString(date: date, outputFormat: .d_MMM_yyyy) ?? "", color: ConfirmationTableViewItemModelColor.normal)
            simpleItems.append(validityDateItem)
        }
        
        if let owner = owner {
            let ownerItem = (stringLoader.getString("confirmation_item_firstHolder"), owner.camelCasedString, color: ConfirmationTableViewItemModelColor.normal)
            simpleItems.append(ownerItem)
        }
        
        let linkedAccountItem = (stringLoader.getString("confirmation_label_associatedAccount"), account?.getAliasAndInfo() ?? IBAN.create(fromText: linkedAccount ?? "").getAliasAndInfo(withCustomAlias: stringLoader.getString("generic_summary_associatedAccount").text), color: ConfirmationTableViewItemModelColor.normal)
        simpleItems.append(linkedAccountItem)
        
        if let linkedAccountAmount = linkedAccountAmount {
            let linkedAccountAmountItem = (stringLoader.getString("confirmation_item_balance"), linkedAccountAmount.getFormattedAmountUI(), color: ConfirmationTableViewItemModelColor.normal)
            simpleItems.append(linkedAccountAmountItem)
        }
        
        let simpleItemsViewModels = simpleItems.enumerated().map {
            ConfirmationTableViewItemModel($1.0,
                                           $1.1,
                                           $0 == simpleItems.count - 1,
                                           dependencies,
                                           $1.2)
        }
        
        simpleItemsViewModels.forEach { stockTradeSection.items.append($0) }
        
        let textItem = OperativeLabelTableModelView(title: stringLoader.getString("confirmation_text_info"),
                                                    style: LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14.0), textAlignment: .center),
                                                    privateComponent: dependencies)
        stockTradeSection.items.append(textItem)
        
        view.sections = [sectionHeader, stockAccountSection, stockTradeSection]
    }
}

extension StocksTradeConfirmationPresenter: StocksTradeConfirmationPresenterProtocol {
    func headerLoaded(model: StockBaseHeaderViewModel) {
        let headerCell = GenericHeaderViewModel(viewModel: model, viewType: StockBaseHeaderView.self, dependencies: dependencies)
        sectionHeader.items = [headerCell]
    }
    
    func confirmButtonTouched() {
        guard let container = container else {
            return
        }
        operative?.mifidLaunched(from: self)
        navigator.launchMifid2(withContainer: container, forOperative: stockTradeData.order.mifidOperative, delegate: self, stringLoader: stringLoader)
    }
}

extension StocksTradeConfirmationPresenter: MifidLauncherPresenterProtocol {
    func performValidate(for mifidContainer: MifidContainerProtocol, onSuccess: @escaping () -> Void) {
        guard let operativeContainer = container, let stockAccount = selectedCCV.stockAccount else {
            return
        }
        
        let input = ValidateStocksTradeUseCaseInput(stockAccount: stockAccount,
                                                    order: stockTradeData.order,
                                                    orderType: orderType,
                                                    configuration: titlesAndDate,
                                                    stock: stockTradeData.stock)
        let useCase = useCaseProvider.validateStocksTradeUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { response in
            if let signature = response.signature {
                operativeContainer.saveParameter(parameter: signature)
            } else {
                mifidContainer.hideCommonLoading { [weak self] in
                    self?.showError(keyDesc: nil, phone: nil)
                }
            }
            
            onSuccess()
        }, onGenericErrorType: { [weak self] errorType in
            mifidContainer.hideCommonLoading { [weak self] in
                switch errorType {
                case .error(let error):
                    self?.showError(keyDesc: error?.getErrorDesc(), phone: nil)
                case .networkUnavailable:
                    self?.showError(keyDesc: "generic_error_needInternetConnection")
                case .generic, .intern, .unauthorized:
                    self?.showError(keyDesc: nil)
                }
                
            }
        })
    }
}
