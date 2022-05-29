import CoreFoundationLib
import Foundation

class StocksTradeOperative: MifidLauncherOperative {
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    var isShareable = true
    var needsReloadGP = false
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.stockTradeOperativeFinishedNavigator
    }
    var tradeType: StocksTradeOrder
    var opinatorPage: OpinatorPage? {
        switch tradeType {
        case .buy:
            return .buyStocks
        case .sell:
            return .sellStocks
        }
    }
    
    var mifidState: MifidState = .unknown
    
    let dependencies: PresentationComponent

    // MARK: - Tracking

    var screenIdSignature: String? {
        switch tradeType {
        case .buy:
            return TrackerPagePrivate.StocksBuySign().page
        case .sell:
            return TrackerPagePrivate.StocksSellSign().page
        }
    }

    var screenIdSummary: String? {
        switch tradeType {
        case .buy:
            return TrackerPagePrivate.StocksBuySummary().page
        case .sell:
            return TrackerPagePrivate.StocksSellSummary().page
        }
    }

    func getTrackParametersSummary() -> [String: String]? {
        guard let container = container else {
            return nil
        }

        let stockBase: StockTradeData = container.provideParameter()
        let orderType: StockTradeOrderType = container.provideParameter()
        let ticker = stockBase.stock.ticker

        if let price = stockBase.stock.price {
            return [TrackerDimensions.amount: price.getTrackerFormattedValue(4),
                    TrackerDimensions.currency: price.currencyName,
                    TrackerDimensions.operationType: orderType.trackerId,
                    TrackerDimensions.ticker: ticker ?? ""]
        } else {
            return nil
        }
    }

    // MARK: -

    init(tradeType: StocksTradeOrder, dependencies: PresentationComponent) {
        self.tradeType = tradeType
        self.dependencies = dependencies
    }
    
    func buildSteps() {
        guard let container = container else {
            return
        }
        let stepsFactory = OperativeStepFactory(presenterProvider: container.presenterProvider)
        let operativeData: SelectedTradingStockAccount = container.provideParameter()
        if !operativeData.isStockAccountSelectedWhenCreated {
            add(step: stepsFactory.createStep() as StocksTradeOperativeCCVSelector)
        }
        add(step: stepsFactory.createStep() as StocksTradeOperativeOrderTypeSelector)
        add(step: stepsFactory.createStep() as StocksTradeOperativeTitlesAndValidityDate)
        add(step: stepsFactory.createStep() as StocksTradeOperativeConfirmation)
        add(step: stepsFactory.createStep() as OperativeSimpleSignature)
        add(step: stepsFactory.createStep() as OperativeSummary)
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else {
            completion(false, nil)
            return
        }
        
        let selectedCCV: SelectedTradingStockAccount = container.provideParameter()
        guard let stockAccount = selectedCCV.stockAccount else {
            return
        }
        let operativeData: StockTradeData = container.provideParameter()
        let orderType: StockTradeOrderType = container.provideParameter()
        let titlesAndDate: OrderTitlesAndDateConfiguration = container.provideParameter()
        let signatureFilled: SignatureFilled<Signature> = container.provideParameter()
    
        let input = ConfirmStocksTradeUseCaseInput(stockAccount: stockAccount,
                                                   order: operativeData.order,
                                                   orderType: orderType,
                                                   configuration: titlesAndDate,
                                                   stock: operativeData.stock,
                                                   signature: signatureFilled.signature)
        let useCase = dependencies.useCaseProvider.confirmStocksTradeUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { _ in
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        
        guard let container = container else {
            return .empty
        }
        
        let operativeData: StockTradeData = container.provideParameter()
        switch operativeData.order {
        case .buy:
            return dependencies.stringLoader.getString("summary_title_orderBuy")
        case .sell:
            return dependencies.stringLoader.getString("summary_title_orderSell")
        }
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        guard let container = container else {
            return nil
        }
        
        let operativeData: StockTradeData = container.provideParameter()
        let orderType: StockTradeOrderType = container.provideParameter()
        let configuration: OrderTitlesAndDateConfiguration = container.provideParameter()
        let prevalidateData: StocksTradePreValidateData = container.provideParameter()
        
        let stringLoader = dependencies.stringLoader
        let timeManager = dependencies.timeManager
        
        var info: [SummaryItemData] = []
        
        let stockName = operativeData.stock.stockName == nil ? "" : "(\(operativeData.stock.ticker!))"
        let stockItemTitle = (operativeData.stock.stockName ?? "") + " \(stockName)"
        let stockItem = StockSummaryData(ticker: stockItemTitle,
                                     price: operativeData.stock.price?.getFormattedAmountUI(4),
                                     variation: operativeData.stock.variation,
                                     comparison: operativeData.stock.variationCompare)
        info.append(stockItem)
        
        let datePart = timeManager.toString(date: operativeData.stock.priceDate, outputFormat: .d_MMM_yyyy) ?? ""
        let dateItem = SimpleSummaryData(field: stringLoader.getString("summary_item_transactionDate"), value: datePart)
        info.append(dateItem)
        
        let timePart = timeManager.toString(date: operativeData.stock.priceTime, outputFormat: .HHmm) ?? ""
        let timeItem = SimpleSummaryData(field: stringLoader.getString("summary_item_hour"), value: timePart)
        info.append(timeItem)
        
        let orderTypeItem = SimpleSummaryData(field: stringLoader.getString("summary_item_kindOrder"), value: orderType.localizedTitle(with: stringLoader).text)
        info.append(orderTypeItem)
        
        if case .byLimitation(let price) = orderType, case .success(let value) = Decimal.getAmountParserResult(value: price) {
            let amount = Amount.createWith(value: value)
            
            let orderTypeItem = SimpleSummaryData(field: stringLoader.getString("summary_item_limit"), value: amount.getFormattedAmountUI(4))
            info.append(orderTypeItem)
        }
        
        let titlesItem = SimpleSummaryData(field: stringLoader.getString("summary_item_numberTitles"), value: configuration.numberOfTitles)
        info.append(titlesItem)
        
        if let validityDate = prevalidateData.limitDate {
            info.append(SimpleSummaryData(field: stringLoader.getString("summary_item_validityPeriod"),
                                          value: timeManager.toString(date: validityDate, outputFormat: .d_MMM_yyyy) ?? ""))
        }
        
        return info
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return nil
    }
}

struct StocksTradeOperativeCCVSelector: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.stockOperatives.stocksTradeOperativeCCVSelectorPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

extension StockTradeOrderType {

    var trackerId: String {
        switch self {
        case .toMarket:
            return "a mercado"
        case .byBest:
            return "por lo mejor"
        case .byLimitation:
            return "limitada"
        }
    }

}

// MARK: - Steps

struct StocksTradeOperativeOrderTypeSelector: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.stockOperatives.orderTypeSelectorPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct StocksTradeOperativeTitlesAndValidityDate: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.stockOperatives.orderTitlesAndDatePresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct StocksTradeOperativeConfirmation: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.stockOperatives.stocksTradeConfirmationPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
