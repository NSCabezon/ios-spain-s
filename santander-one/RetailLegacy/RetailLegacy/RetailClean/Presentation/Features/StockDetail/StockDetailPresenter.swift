import Foundation
import CoreFoundationLib

protocol StockDetailNavigatorProtocol: MenuNavigator, OperativesNavigatorProtocol { }

class StockDetailPresenter: PrivatePresenter<StockDetailViewController, StockDetailNavigatorProtocol & PullOffersActionsNavigatorProtocol, StockDetailPresenterProtocol> {
    var stock: Stock?
    var stockAccount: StockAccount?
    var stockQuote: StockQuote?
    let origin: StockDetailNavigationOrigin
    var numberOfTitles = 0
    var numberOfTitlesInAccount = 0
    var productConfig: ProductConfig?
    
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().stocksHome
    }
    
    lazy var usecase = LoadStockSuperUseCase(useCaseProvider: dependencies.useCaseProvider, useCaseHandler: dependencies.secondaryUseCaseHandler)

    // MARK: - TrackerScreenProtocol

    override var screenId: String? {
        return TrackerPagePrivate.StocksDetailValue().page
    }

    // MARK: -
    private var presenterOffers: [PullOfferLocation: Offer] = [:]

    private var stockForTrading: StockBase? {
        let stockBase: StockBase?
        if let stockQuote = stockQuote {
            stockBase = stockQuote
        } else if let stock = stock {
            stockBase = stock
        } else {
            stockBase = nil
        }
        return stockBase
    }
    
    init(_ dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: StockDetailNavigatorProtocol & PullOffersActionsNavigatorProtocol, stock: Stock?, stockAccount: StockAccount?, stockQuote: StockQuote?, origin: StockDetailNavigationOrigin) {
        self.stock = stock
        self.stockAccount = stockAccount
        self.stockQuote = stockQuote
        self.origin = origin
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
        self.barButtons = [.menu]
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.title = stringLoader.getString("toolbar_title_stocksDetail").text
        view.buyButtonTitle = stringLoader.getString("stocks_button_buy").uppercased()
        view.sellButtonTitle = stringLoader.getString("stocks_button_sell").uppercased()
        view.buttonsHidden = true
        loadProductConfig { [weak self] in
            self?.getLocations { [weak self] in
                self?.loadStockInfo()
            }
        }
    }
    
    private func getLocations(completion: @escaping () -> Void) {
        getCandidateOffers { [weak self] candidates in
            self?.presenterOffers = candidates
            completion()
        }
    }
    
    private func loadProductConfig(_ completion: @escaping () -> Void) {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getProductConfigUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: errorHandler,
            onSuccess: { [weak self] response in
                self?.productConfig = response.productConfig
                completion()
            },
            onError: { _ in
                completion()
        })
    }
}

extension StockDetailPresenter: Presenter {
    
    private func loadStockInfo() {
        view.dateLabelText = ""
        if origin == StockDetailNavigationOrigin.stocksHome {
            guard let stock = stock else {
                return
            }
            
            numberOfTitles = stock.numberOfTitles
            loadUpperViewData(stock: stock)
            loadDetailData(stock: stock)
            loadButtonsForOriginProductsHome()
        } else {
            view.currentStockLabel.text = ""
            loadUpperViewData(stock: stockQuote)
            numberOfTitles = 0
            view.setEmptyCurrentStockShares()
            view.setLoadingViewVisibility(visible: true)
            usecase.clousureFinish = { [weak self] (stocksByAccount, ibexSan) in
                if ibexSan == nil { return }
                if let presenter = self {
                    if let stock = presenter.stock, let localId = stock.getLocalId() {
                        presenter.numberOfTitles = stocksByAccount.map {_, stocks in
                            return stocks.numberOfTitles(forLocalId: localId)
                        }.reduce(0, +)
                        presenter.numberOfTitlesInAccount = stocksByAccount.map { stockAccount, stocks in
                            if stockAccount.getOriginFromType() == .rvManaged {
                                return 0
                            }
                            return stocks.numberOfTitles(forLocalId: localId)
                        }.reduce(0, +)
                    } else {
                        presenter.numberOfTitlesInAccount = 0
                        presenter.numberOfTitles = 0
                    }
                    presenter.view.setLoadingViewVisibility(visible: false)
                    presenter.loadUpperViewData(stock: presenter.stockQuote)
                    presenter.loadDetailData(stock: presenter.stockQuote)
                    presenter.loadButtonsForOriginSearch()
                }
            }
            let input = GetAllStockAccountsUseCaseInput(firstListOrigin: StockAccountOrigin.regular)
            UseCaseWrapper(with: dependencies.useCaseProvider.getAllStockAccountsUseCase(input: input), useCaseHandler: dependencies.useCaseHandler, errorHandler: nil, onSuccess: { [weak self] result in
                if let selfUnwrapped = self {
                    let stockAccounts = result.stockAccountList.list
                    selfUnwrapped.usecase.getStocks(stockAccounts: stockAccounts, first: 0)
                }
            })
        }
    }
    
    private func setRMVButtonsVisibility() {
        if stockAccount?.getOriginFromType() == .rvManaged {
            view.buttonsHidden = true
        }
    }
    
    private func loadButtonsForOriginProductsHome() {
        if stock != nil {
            (numberOfTitles == 0) ? view.configureOneButton(type: .buy) : view.configureTwoButtons()
            setVisibilityBuySellButtons()
        }
    }
    
    private func loadButtonsForOriginSearch() {
        if stock != nil {
            (numberOfTitlesInAccount == 0) ? view.configureOneButton(type: .sale) : view.configureTwoButtons()
        } else {
            view.configureOneButton(type: .buy)
        }
        view.buttonsHidden = false
    }
    
    private func setVisibilityBuySellButtons() {
        let isDetailLoaded = stock?.state == .done
        let isButtonsActive = !(stockAccount?.getOriginFromType() == .rvManaged)
        view.buttonsHidden = !isButtonsActive || !isDetailLoaded
    }
    
    public func loadUpperViewData(stock: StockBase?) {
        
        guard let stock = stock else {
            return
        }
        
        if let date = stock.priceDate, let time = stock.priceTime {
            let dateString = dependencies.timeManager.toString(date: date, outputFormat: TimeFormat.d_MMM_yyyy) ?? ""
            let timeString = dependencies.timeManager.toString(date: time, outputFormat: TimeFormat.HHmm) ?? ""
            view.dateLabelText = "\(dateString) - \(timeString)"
        }
        
        view.stockNameLabelText = stock.name ?? ""
        view.stockValueLabelText = stock.price?.getFormattedAmountUI(4) ?? ""
        
        view.setVariation(variation: stock.variation, compareZero: stock.variationCompare)
        
        if numberOfTitles > 0 && origin == StockDetailNavigationOrigin.stocksHome {
            let placeholder = StringPlaceholder(StringPlaceholder.Placeholder.number, "\(numberOfTitles)".insertIntegerSeparator(separator: "."))
            view.setCurrentStockShares(titleInfo: localized(key: "stocksDetail_text_titlesStock", count: numberOfTitles, stringPlaceHolder: [placeholder]), imageType: StockDetailImageType.icnBag)
        } else if numberOfTitles > 0 && origin == StockDetailNavigationOrigin.stocksSearch {
            let placeholder = StringPlaceholder(StringPlaceholder.Placeholder.number, "\(numberOfTitles)".insertIntegerSeparator(separator: "."))
            view.setCurrentStockShares(titleInfo: localized(key: "stocksDetail_text_totalTitles", count: numberOfTitles, stringPlaceHolder: [placeholder]), imageType: StockDetailImageType.icnBag)
        } else {
            view.setCurrentStockShares(titleInfo: localized(key: "stocksDetail_text_noTitlesStock"), imageType: StockDetailImageType.icnBag)
        }
    }
    
    private func loadDetailData(stock: StockBase?) {
        guard let stock = stock else {
            return
        }
        
        if stock.quoteDetailDto == nil {
            view.setLoadingViewVisibility(visible: true)
            view.setRMVLoadingViewVisibility(visible: true)
            let stockQuoteCaseInput = GetStockQuoteDetailUseCaseInput(stock: stock)
            UseCaseWrapper(with: useCaseProvider.getStockQuoteDetailUseCase(input: stockQuoteCaseInput), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (_) in
                
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.loadUpperViewTableView()
                strongSelf.view.setLoadingViewVisibility(visible: false)
                strongSelf.loadRMVData()
                
            }, onGenericErrorType: { [weak self] (_) in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.view.onDetailLoadError()
                strongSelf.view.setRMVLoadingViewVisibility(visible: false)
                strongSelf.view.onRMVLoadError()
                
            })
        } else {
            loadUpperViewTableView()
            loadRMVData()
        }
    }
    
    public func loadUpperViewTableView() {
        
        var sections = [TableModelViewSection]()
        
        let infoSections = TableModelViewSection()
        
        if let stockFormatted = stock, let modelView = getModelViewForCurrentStockValuation(stock: stockFormatted) {
            infoSections.add(item: modelView)
        }
        
        let baseStock: StockBase? = stockQuote ?? stock
        
        if let baseStock = baseStock {
            let dailyHigh = baseStock.quoteDetailDto?.dailyHigh?.value?.getFormattedAmountUI(currencySymbol: (baseStock.quoteDetailDto?.dailyHigh?.currency?.getSymbol()) ?? "", 4) ?? ""
            let dailyLow = baseStock.quoteDetailDto?.dailyLow?.value?.getFormattedAmountUI(currencySymbol: (baseStock.quoteDetailDto?.dailyLow?.currency?.getSymbol()) ?? "", 4) ?? ""
            let titleViewModel3 = StockDetailInfoTwoElementsModelView(firstTitleInfo: localized(key: "stocksDetail_text_max"), firstValueInfo: dailyHigh, secondTitleInfo: localized(key: "stocksDetail_text_min"), secondValueInfo: dailyLow, dependencies: dependencies)
            infoSections.add(item: titleViewModel3)
            
            let dailyOpen = baseStock.quoteDetailDto?.openingPrice?.value?.getFormattedAmountUI(currencySymbol: (baseStock.quoteDetailDto?.openingPrice?.currency?.getSymbol()) ?? "", 4) ?? ""
            let dailyClose = baseStock.quoteDetailDto?.closingPrice?.value?.getFormattedAmountUI(currencySymbol: (baseStock.quoteDetailDto?.closingPrice?.currency?.getSymbol()) ?? "", 4) ?? ""
            let titleViewModel4 = StockDetailInfoTwoElementsModelView(firstTitleInfo: localized(key: "stocksDetail_text_open"), firstValueInfo: dailyOpen, secondTitleInfo: localized(key: "stocksDetail_text_close"), secondValueInfo: dailyClose, dependencies: dependencies)
            infoSections.add(item: titleViewModel4)
            
            var volumeString = ""
            if let volume = baseStock.quoteDetailDto?.volume {
                volumeString = String(describing: volume)
            }
            
            let titleViewModel5 = StockDetailInfoOneElementModelView(firstTitleInfo: localized(key: "stocksDetail_text_dimension"), firstValueInfo: volumeString.insertIntegerSeparator(separator: "."), dependencies: dependencies)
            infoSections.add(item: titleViewModel5)
        }
        
        sections.append(infoSections)
        
        view.sections = sections
    }
    
    private func loadRMVData() {
        guard let stockAccount = stockAccount, let stock = stock else {
            view.setRMVLoadingViewVisibility(visible: false)
            view.onRMVLoadError()
            return
        }
        
        view.setRMVLoadingViewVisibility(visible: true)
        let caseInput = GetCounterValueDetailUseCaseInput(stockAccount: stockAccount, stock: stock)
        UseCaseWrapper(with: useCaseProvider.getCounterValueDetailUseCase(input: caseInput), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.loadLowerViewData(rmv: response.rmvDetail)
            strongSelf.view.setRMVLoadingViewVisibility(visible: false)
            strongSelf.setRMVButtonsVisibility()
            
        }, onGenericErrorType: { [weak self] (_) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.view.onRMVLoadError()
        })
    }
    
    private func getModelViewForCurrentStockValuation(stock: Stock) -> StockDetailInfoWithoutImageModelView? {
        
        guard let quotePrice = (stockQuote ?? stock).price?.value else {
            return nil
        }
        
        let decimalPrice = abs(quotePrice)
        let totalPrice = decimalPrice * Decimal(numberOfTitles)
        let amount = Amount.createWith(value: totalPrice)
        
        let placeholder2 = StringPlaceholder(StringPlaceholder.Placeholder.number, amount.getAbsFormattedAmountUI())
        let localizedString = (origin == StockDetailNavigationOrigin.stocksHome) ? "stocksDetail_text_stockValuation" : "stocksDetail_text_totalValuation"
        let titleInfo = localized(key: localizedString, stringPlaceHolder: [placeholder2])
        let titleViewModel2 = StockDetailInfoWithoutImageModelView(titleInfo: titleInfo, dependencies: dependencies)
        
        return titleViewModel2
    }
    
    public func loadLowerViewData(rmv: RMVDetail) {
        var rmvSections = [TableModelViewSection]()
        let section = TableModelViewSection()
        let header = StockDetailRMVModelView(firstText: LocalizedStylableText(text: "", styles: nil),
                                             secondText: localized(key: "stocksDetail_text_titlesTable"),
                                             thirdText: localized(key: "stocksDetail_text_dateTable"),
                                             fourthText: localized(key: "stocksDetail_text_quotationTable"),
                                             fifthText: localized(key: "stocksDetail_text_assessmentTable"),
                                             isHeader: true,
                                             dependencies: dependencies)
        section.add(item: header)
        
        for row in rmv.rmvDetailDTO.rmvLineDetailModelList.filter({$0.columnDesc != nil}) {
            let firstText = row.columnDesc != nil ? (row.columnDesc! != "" ? row.columnDesc! : "") : ""
            let secondText = row.sharesCount != nil ? (row.sharesCount! != Decimal(0) ? row.sharesCount!.getFormattedValue(0) : "") : ""
            var thirdText = ""
            if let priceDate = row.priceDate {
                let date = dependencies.timeManager.fromString(input: priceDate, inputFormat: TimeFormat.yyyyMMdd)
                thirdText = dependencies.timeManager.toString(date: date, outputFormat: TimeFormat.ddMMyyyy) ?? ""
            }
            let fourthText = row.priceAmount != nil ? (row.priceAmount!.value != Decimal(0) ? row.priceAmount?.value?.getFormattedAmountUIWith1M(currencySymbol: row.priceAmount?.currency?.getSymbol() ?? "") : "") : ""
            let fifthText = row.valueAmount != nil
                ? (row.valueAmount!.value != Decimal(0) ? row.valueAmount?.value?.getFormattedAmountUIWith1M(currencySymbol: row.valueAmount?.currency?.getSymbol() ?? "") : "") : ""
            let newRow = StockDetailRMVModelView(firstText: LocalizedStylableText(text: firstText, styles: nil),
                                                 secondText: LocalizedStylableText(text: secondText, styles: nil),
                                                 thirdText: LocalizedStylableText(text: thirdText, styles: nil),
                                                 fourthText: LocalizedStylableText(text: fourthText ?? "", styles: nil),
                                                 fifthText: LocalizedStylableText(text: fifthText ?? "", styles: nil),
                                                 isHeader: false, dependencies: dependencies)
            section.add(item: newRow)
        }
        
        rmvSections.append(section)
        
        view.rmvSections = rmvSections
    }
}

extension StockDetailPresenter: StockDetailPresenterProtocol {
    var contentTitle: LocalizedStylableText {
        return stringLoader.getString("orderKind_label_buy")
    }
    
    var moreInfo: LocalizedStylableText {
        return stringLoader.getString("ordersDetail_text_info")
    }
    
    var cancelOrder: LocalizedStylableText {
        return stringLoader.getString("orderDetails_buton_cancelOrder")
    }
    
    func buyButtonTouched() {
        guard let stock = stockForTrading else {
            return
        }
        let location: PullOfferLocation = (stockAccount != nil) ? .SOFIA_BUY_DETAIL: .SOFIA_SEARCH_BUY
        if let offer = self.presenterOffers[location] {
            self.didSelectBanner(offer: offer, location: location)
        } else {
            launch(forStock: stock, in: stockAccount, tradeType: .buy, withDelegate: self)
        }
    }
    
    func sellButtonTouched() {
        guard let stock = stockForTrading else {
            return
        }
        let location: PullOfferLocation = (stockAccount != nil) ? .SOFIA_SELL_DETAIL: .SOFIA_SEARCH_SELL
        if let offer = self.presenterOffers[location] {
            self.didSelectBanner(offer: offer, location: location)
        } else {
            launch(forStock: stock, in: stockAccount, tradeType: .sell, withDelegate: self)
        }
    }
    
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    private func didSelectBanner(offer: Offer, location: PullOfferLocation) {
        guard let action = offer.action else {
            return
        }
        executeOffer(action: action, offerId: offer.id, location: location)
    }
}

extension StockDetailPresenter: ProductLauncherPresentationDelegate {
    func startLoading() {
        let type = LoadingViewType.onScreen(controller: view, completion: nil)
        let text = LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        showLoading(info: info)
    }
    
    func endLoading(completion: (() -> Void)?) {
        hideLoading(completion: completion)
    }
    
    func showAlert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?) {
        Dialog.alert(title: title, body: message, withAcceptComponent: accept, withCancelComponent: cancel, showsCloseButton: false, source: view)
    }
    
    func showAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        showError(keyTitle: keyTitle, keyDesc: keyDesc, completion: completion)
    }
}

extension StockDetailPresenter: StocksTradeLauncher {
    var operativesNavigator: OperativesNavigatorProtocol {
        return navigator
    }
    
    var errorHandler: GenericPresenterErrorHandler {
        return genericErrorHandler
    }
}

extension StockDetailPresenter: PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}

extension StockDetailPresenter: LocationsResolver {}

extension StockDetailPresenter {
    func actionData() -> ProductWebviewParameters? {
        let stockWebviewParameters: StockWebviewParameters = StockWebviewParameters(contractId: stockAccount?.getContract() ?? "", stockCode: stock?.getStockCode(), identificationNumber: stock?.getIdentificationNumber())
        return stockWebviewParameters
    }
}
