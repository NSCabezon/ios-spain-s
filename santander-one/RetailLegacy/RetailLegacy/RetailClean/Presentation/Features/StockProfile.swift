import CoreFoundationLib
import UIKit
import CoreDomain

class StockProfile: BaseProductHomeProfile<StockAccount, Void, Void, Void, StringErrorOutput, Stock>, ProductProfile, LoadStockQuotesSuperUseCaseDelegate, LoadStockSuperUseCaseDelegate, SingleSignOn {
    
    var menuOptionSelected: PrivateMenuOptions? {
        return .myProducts
    }
    
    weak var superUsecase: LoadStockSuperUseCase?
    let navigator: StockProfileNavigatorProtocol
    let appStoreNavigator: AppStoreNavigatable
    lazy var usecaseQuotes: LoadStockQuotesSuperUseCase = LoadStockQuotesSuperUseCase(useCaseProvider: dependencies.useCaseProvider, useCaseHandler: dependencies.secondaryUseCaseHandler, delegate: self, errorHandler: errorHandler)

    override var isHeaderCellHidden: Bool {
        return false
    }
    
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().stocksHome
    }
    var stock: Stock?
    var stockAccount: StockAccount?
    
    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return TrackerPagePrivate.Stocks().page
    }
    
    // MARK: - 
    private var presenterOffers: [PullOfferLocation: Offer] = [:]
    private lazy var options = [ProductOption]()

    init(appStoreNavigator: AppStoreNavigatable, selectedProduct: GenericProduct?, dependencies: PresentationComponent, errorHandler: GenericPresenterErrorHandler, delegate: ProductHomeProfileDelegate, shareDelegate: ShowShareType?) {
        self.appStoreNavigator = appStoreNavigator
        navigator = dependencies.navigatorProvider.stockProfileNavigator
        super.init(selectedProduct: selectedProduct, dependencies: dependencies, errorHandler: errorHandler, delegate: delegate, shareDelegate: shareDelegate)
        getLocations()
    }
    
    deinit {
        usecaseQuotes.cancelAll()
    }
    
    private func getLocations() {
        getCandidateOffers { [weak self] candidates in
            self?.presenterOffers = candidates
        }
    }
    
    override func convertToProductHeader(element: StockAccount, position: Int) -> CarouselItem {
        let data = ProductHeader(title: element.getAliasUpperCase(),
                                 subtitle: element.getDetailUI(),
                                 amount: element.getAmount(),
                                 pendingText: nil,
                                 isPending: false,
                                 isCopyButtonAvailable: true,
                                 copyTag: nil,
                                 isBigSeparator: needsExtraBottomSpace,
                                 shareDelegate: self)
        return CarouselGenericCell(data: data)
    }
    
    var loadingPlaceholder: Placeholder {
        return Placeholder("stockPlaceholderFakeList", 14)
    }
    
    override var loadingTopInset: Double {
        return 0
    }
    
    var showNavigationInfo: Bool {
        return false
    }
    
    var productTitle: LocalizedStylableText {
        if let stockAccount = self.selectedProduct as? StockAccount {
            if let stockAccountType = stockAccount.stockAccountType {
                switch stockAccountType {
                case .RVManaged:
                    return dependencies.stringLoader.getString("toolbar_title_portfolioManaged")
                case .RVNotManaged:
                    return dependencies.stringLoader.getString("toolbar_title_portfolioNoManaged")
                default:
                    break
                }
            }
        }
        
        return dependencies.stringLoader.getString("toolbar_title_stocks")
    }
        
    override var transactionHeaderTitle: LocalizedStylableText? {
        return dependencies.stringLoader.getString("stocks_label_myStoks").uppercased()
    }
    
    var isFilterIconVisible: Bool {
        return false
    }
    
    override func extractProductList(globalPosition: GlobalPositionWrapper) -> [StockAccount] {
        
        if let stockAccount = self.selectedProduct as? StockAccount {
            if let stockAccountType = stockAccount.stockAccountType {
                switch stockAccountType {
                case .RVManaged:
                    return globalPosition.managedRVStockAccounts.get(ordered: true, visibles: true)
                case .RVNotManaged:
                    return globalPosition.notManagedRVStockAccounts.get(ordered: true, visibles: true)
                default:
                    break
                }
            }
        }
        
        return globalPosition.stockAccounts.get(ordered: true, visibles: true)
    }
    
    override func useCaseForTransactions<Input, Response, Error: StringErrorOutput>(pagination: PaginationDO?) -> UseCase<Input, Response, Error>? {
        return nil
    }
    
    override func requestTransactions(fromBeginning isFromBeginning: Bool, completion: @escaping ([DateProvider]) -> Void) {
        
        guard let currentPosition = currentPosition else {
            return
        }
        
        transactionsCompletionHandler = completion
        if let result = superUsecase?.getStock(position: currentPosition) {
            switch result {
            case .loading:
                break
            case .error:
                DispatchQueue.main.async {
                    self.receivedTransactions(transactions: nil, nextPage: nil)
                }
            case .success(_, let transactions):
                transactionList.append(contentsOf: transactions)
                DispatchQueue.main.async {
                    self.receivedTransactions(transactions: transactions, nextPage: nil)
                }
            }
        }
    }
    
    override func paginationFrom(response: Void) -> PaginationDO? {
        return nil
    }
    
    override func transactionsFrom(response: Void) -> [Stock]? {
        return nil
    }
    
    override func convertToDateProvider(from transaction: Stock) -> DateProvider {
        var stockOrigin = StockAccountOrigin.regular
        if let stockAccount = self.selectedProduct as? StockAccount {
            stockOrigin = stockAccount.getOriginFromType()
        }
        
        let isManaged = stockOrigin == .rvManaged
        let isBuyActive = !isManaged
        let isSellActive = !isManaged

        return StockModelView(transaction, isManaged: isManaged, isBuyActive: isBuyActive, isSellActive: isSellActive, actionBuy: { [weak self] _ in
            guard let thisProfile = self, let currentPosition = thisProfile.currentPosition, let delegate = thisProfile.delegate else {
                return
            }
            thisProfile.stock = transaction
            thisProfile.stockAccount = thisProfile.productList[currentPosition]
            
            if let offer = self?.presenterOffers[.SOFIA_BUY_LIST] {
                self?.didSelectBanner(offer: offer, location: .SOFIA_BUY_LIST)
            } else {
                thisProfile.launch(forStock: transaction, in: thisProfile.productList[currentPosition], tradeType: .buy, withDelegate: delegate)
            }
        }, actionSell: { [weak self] _ in
            guard let thisProfile = self, let currentPosition = thisProfile.currentPosition, let delegate = thisProfile.delegate else {
                return
            }
            thisProfile.stock = transaction
            thisProfile.stockAccount = thisProfile.productList[currentPosition]
            
            if let offer = self?.presenterOffers[.SOFIA_SELL_LIST] {
                self?.didSelectBanner(offer: offer, location: .SOFIA_SELL_LIST)
            } else {
                thisProfile.launch(forStock: transaction, in: thisProfile.productList[currentPosition], tradeType: .sell, withDelegate: delegate)
            }
        }, dependencies)
    }
    
    // MARK: - MenuOptions
    override func menuOptions(withProductConfig productConfig: ProductConfig) {
        if !options.isEmpty { options.removeAll() }
        
        options.append(StockOptionsHandler.buildAllStocks(dependencies))
        options.append(StockOptionsHandler.buildSearchStocks(dependencies))

        if productConfig.enableBroker == true {
            options.append(StockOptionsHandler.buildBroker(dependencies))
            options.append(StockOptionsHandler.buildAlerts(dependencies))
        }
        completionOptions?(options)
    }
    
    func optionDidSelected(at index: Int) {
        if let profileOptions = ProductsOptions.StockProfileOptions(rawValue: index) {
            switch profileOptions {
            case .allStocks:
                if let offer = self.presenterOffers[.SOFIA_ORDENES_LIST] {
                        self.didSelectBanner(offer: offer, location: .SOFIA_ORDENES_LIST)
                } else {
                    if let position = currentPosition {
                        let product = productList[position]
                        delegate?.goToTransactionDetail(product: product, transactions: transactionList, selectedPosition: index, productHome: .orders)
                    }
                }
            case .search:
                if let offer = self.presenterOffers[.SOFIA_SEARCH_LIST] {
                    self.didSelectBanner(offer: offer, location: .SOFIA_SEARCH_LIST)
                } else {
                    delegate?.goToSearchStocks(usecase: superUsecase)
                }
            case .broker:
                showSOFIA()
            case .alerts:
                goToAlertsConfiguration()
            }
        }
    }
    
    func transactionDidSelected(at index: Int) {
        if let stockAccount = currentProduct as? StockAccount {
            let stock = transactionList[index]
            
            if stock.state != .loading {
                delegate?.goStocksDetail(stock: stock, stockAccount: stockAccount)
            }
        }
    }
    
    func showInfo() {}
    
    func displayIndex(index: Int) {
        if transactionList.count > index {
            let stock = transactionList[index]
            if stock.state == .loading {
                usecaseQuotes.getDetailQuote(stock: stock, index: index)
            }
        }
    }
    
    func endDisplayIndex(index: Int) {
        usecaseQuotes.cancelIndex(index: index)
    }
    
    override func infoToShareWithCode(_ code: Int?) -> String? {
        let position = currentPosition ?? 0
        let product = productList[position]
        let info = product.getDetailUI()

        return info
    }
    
    private func didSelectBanner(offer: Offer, location: PullOfferLocation) {
        guard let action = offer.action else {
            return
        }
        dependencies.trackerManager.trackEvent(
            screenId: screenId ?? "",
            eventId: TrackerPagePrivate.Generic.Action.inOffer.rawValue,
            extraParameters: [
                TrackerDimensions.offerId: offer.id ?? ""
            ]
        )
        delegate?.executePullOfferAction(action: action, offerId: offer.id, location: location)
    }
    
// MARK: - LoadStockQuotesSuperUseCaseDelegate

    func updateIndex (index: Int) {
        delegate?.updateIndex(index: index)
    }

// MARK: - LoadStockSuperUseCaseDelegate

    func updateStockAccount (position: Int) {
        if position == currentPosition, let transactionsCompletionHandler = transactionsCompletionHandler {
            requestTransactions(completion: transactionsCompletionHandler)
        }
    }
}

extension StockProfile: StocksTradeLauncher {
    var operativesNavigator: OperativesNavigatorProtocol {
        return navigator
    }
}

extension StockProfile: SOFIALauncher {
    var sofiaLauncherNavigator: SOFIALauncherNavigatorProtocol {
        return navigator
    }
}

extension StockProfile: StocksAlertsConfigurationLauncher {
    var stocksAlertsConfigurationLauncherNavigator: StocksAlertsConfigurationLauncherNavigatorProtocol {
        return navigator
    }
}

extension StockProfile: LocationsResolver {
    var useCaseProvider: UseCaseProvider {
        return dependencies.useCaseProvider
    }
    
    var useCaseHandler: UseCaseHandler {
        return dependencies.useCaseHandler
    }
    
    var genericErrorHandler: GenericPresenterErrorHandler {
        return errorHandler
    }
}

extension StockProfile {
    func actionData() -> ProductWebviewParameters? {
        let stockWebviewParameters: StockWebviewParameters = StockWebviewParameters(contractId: stockAccount?.getContract() ?? "", stockCode: stock?.getStockCode(), identificationNumber: stock?.getIdentificationNumber())
        return stockWebviewParameters
    }
}
