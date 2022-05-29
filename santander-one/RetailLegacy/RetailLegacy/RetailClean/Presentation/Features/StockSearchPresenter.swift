import Foundation

enum StockSearchState {
    case loading
    case ibex
    case searching
    case searched
}

protocol StockSearchNavigatorProtocol: MenuNavigator {
    func goToStockDetail(stockQuote: StockQuote, stock: Stock?)
}

class StockSearchPresenter: PrivatePresenter<StockSearchViewController, StockSearchNavigatorProtocol, StockSearchPresenterProtocol> {

    // MARK: - TrackerScreenProtocol

    override var screenId: String? {
        return TrackerPagePrivate.StocksSearch().page
    }

    // MARK: -

    private var stocksByAccount: [StockAccount: [Stock]]?
    private var ibexSan: IbexSanQuotes?
    private lazy var usecaseQuotes: LoadStockQuotesSuperUseCase = LoadStockQuotesSuperUseCase(useCaseProvider: useCaseProvider, useCaseHandler: dependencies.secondaryUseCaseHandler, delegate: self, errorHandler: genericErrorHandler)
    private var usecase: LoadStockSuperUseCase?
    private var viewIsPrepared = false
    private var dataIsPrepared = false
    private var quotesSearch: [StockQuote] = []
    private var state = StockSearchState.loading
    private let indexIbex: Int = -1
    private let timeWaiting = 2.0
    private var workTask: DispatchWorkItem?
    private var lastSearchedText: String?
    private var searchingText: String?
    private var pagination: PaginationDO?
    private var onSearch: Bool = false
    private var searchingId: Int = 0
    private var searchingPageId: Int = 0
    private var globalTask: Int = 0
    
    // MARK: - Class Methods
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = dependencies.stringLoader.getString("toolbar_title_searchStock")
        viewIsPrepared = true
        view.setPlaceholder(text: dependencies.stringLoader.getString("searchStock_hint_stock"))
        updateHeader()
        if dataIsPrepared {
            configureInitialData()
            showIntialData()
        } else {
            showLoading()
        }
    }
    
    func assignStockLoader(usecase: LoadStockSuperUseCase) {
        self.usecase = usecase
        usecase.clousureFinish = { [weak self] (stocksByAccount, ibexSan) in
            if let presenter = self {
                presenter.stocksByAccount = stocksByAccount
                presenter.ibexSan = ibexSan
                if let san = ibexSan?.san {
                    presenter.updateQuote(stockQuote: san)
                }
                presenter.dataIsPrepared = true
                if presenter.viewIsPrepared {
                    presenter.hideLoading()
                    presenter.configureInitialData()
                    presenter.showIntialData()
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func isPaggingEnabled() -> Bool {
        if let endList = pagination?.endList {
            return !endList
        } else {
            return false
        }
    }
    
    private func checkCorrectSearching(text: String, taskId: Int) -> Bool {
        switch state {
        case .searching:
            return searchingText == text && lastSearchedText != text && searchingId == taskId
        case .searched:
            return lastSearchedText == text && isPaggingEnabled() && searchingPageId == taskId
        default:
            return false
        }
    }
    
    private func replaceQuotesSection(section: [StockQuoteSearchModelView], empty: Bool = true) {
        usecaseQuotes.cancelAll()
        view.dataSource.replaceQuotesSection(section: section)
        if section.count == 0 && empty {
            let model = EmptyViewModelView(dependencies.stringLoader.getString("generic_label_emptyListResult"), dependencies)
            view.dataSource.showEmptySection(item: model)
        } else {
            view.dataSource.hideEmptySection()
            if isPaggingEnabled() {
                let loading = SecondaryLoadingModelView(dependencies: dependencies)
                view.dataSource.showPaginationSection(item: loading)
            }
        }
    }

    private func searchText(text: String) {
        guard !onSearch else {
            return
        }
        onSearch = true
        let task = globalTask
        globalTask += 1
        let searchPagination: PaginationDO?
        switch state {
        case .searching:
            searchingId = task
            searchPagination = nil
        case .searched:
            searchingPageId = task
            searchPagination = pagination
        default:
            searchPagination = nil
        }

        trackEvent(eventId: TrackerPagePrivate.Generic.Action.search.rawValue, parameters: [TrackerDimensions.textSearch: text])

        let input = GetStocksQuoteSearchUseCaseInput(searchTerms: text, pagination: searchPagination)
        let usecase = dependencies.useCaseProvider.getStockQuoteSearchUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
            guard let presenter = self, presenter.checkCorrectSearching(text: text, taskId: task) else {
                return
            }
            presenter.onSearch = false
            presenter.state = .searched
            presenter.updateHeader()
            let model = response.stockQuotes.map({ (quote) -> StockQuoteSearchModelView in
                self?.updateQuote(stockQuote: quote)
                return StockQuoteSearchModelView(quote: quote, dependencies: presenter.dependencies)
            })
            let isPaging = presenter.isPaggingEnabled()
            presenter.pagination = response.pagination
            if isPaging {
                presenter.quotesSearch.append(contentsOf: response.stockQuotes)
                presenter.view.dataSource.insertQuotesSection(section: model)
                presenter.view.dataSource.hidePaginationSection()
            } else {
                presenter.lastSearchedText = text
                presenter.quotesSearch = response.stockQuotes
                presenter.view.dataSource.hideLoadingSection()
                presenter.replaceQuotesSection(section: model)
            }
        }, onGenericErrorType: { [weak self] _ in
            guard let presenter = self, presenter.checkCorrectSearching(text: text, taskId: task) else {
               return
            }
            presenter.onSearch = false
            if presenter.isPaggingEnabled() {
                presenter.pagination = nil
                presenter.view.dataSource.hidePaginationSection()
            } else {
                presenter.quotesSearch = []
                presenter.pagination = nil
                presenter.replaceQuotesSection(section: [])
                presenter.view.dataSource.hideLoadingSection()
            }
        })
    }
    
    private func showLoading() {
        let type = LoadingViewType.onView(view: view.view, frame: nil, position: .center, controller: view)
        let text = LoadingText(title: localized(key: "generic_popup_loadingContent"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: [Placeholder("stockPlaceholderFakeSearch", 0)], topInset: nil)
        showLoading(info: info)
    }
    
    private func hideLoading() {
        hideLoading(completion: nil)
    }
    
    private func showIntialData() {
        lastSearchedText = nil
        state = .ibex
        updateHeader()
        quotesSearch.removeAll()
        if let sanQuote = ibexSan?.san {
            quotesSearch.append(sanQuote)
            let model = [StockQuoteSearchModelView(quote: sanQuote, dependencies: dependencies)]
            replaceQuotesSection(section: model)
        } else {
            replaceQuotesSection(section: [], empty: false)
        }
        pagination = nil
    }
    
    private func configureInitialData() {
        if let ibexQuote = ibexSan?.ibex {
            usecaseQuotes.getDetailQuote(stock: ibexQuote, index: indexIbex)
        }
    }
    
    private func updateHeader() {
        let text: LocalizedStylableText
        switch state {
        case .loading:
            text = .empty
        case .ibex:
            text = dependencies.stringLoader.getString("searchStock_text_ibexCoatization", [StringPlaceholder(.number, ibexSan?.ibex?.priceTitle ?? "-")])
        case .searching, .searched:
            text = dependencies.stringLoader.getString("searchStock_text_result")
        }
        view.setHeader(text: text)
    }
    
    private func updateQuote(stockQuote: StockQuote) {
        if let identifier = stockQuote.getLocalId(), let stocksByAccount = stocksByAccount {
            let stocks = Array(stocksByAccount.values.map({ $0.filter(byLocalId: identifier) }).joined())
            stockQuote.updateAmount(stocks: stocks)
        }
    }
}

// MARK: - StockSearchPresenterProtocol

extension StockSearchPresenter: StockSearchPresenterProtocol {
    
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    func willDisplayIndex(index: Int) {
        guard quotesSearch.count > index else {
            return
        }
        let stock = quotesSearch[index]
        if stock.state == .loading {
            usecaseQuotes.getDetailQuote(stock: stock, index: index)
        }
        if state == .searched, index == quotesSearch.count - 1, isPaggingEnabled(), let text = lastSearchedText {
            searchText(text: text)
        }
    }
    
    func endDisplayIndex(index: Int) {
    }
    
    func selectIndex(index: Int) {
        let selectedQuote = quotesSearch[index]

        if let stocksByAccount = stocksByAccount {
            let stocks = Array(stocksByAccount.values.map({ $0.filter(byLocalId: selectedQuote.getLocalId() ?? "") }).joined())
            navigator.goToStockDetail(stockQuote: selectedQuote, stock: stocks.first)
        } else {
            navigator.goToStockDetail(stockQuote: selectedQuote, stock: nil)
        }
    }

    func textWasChanged(text: String) {
        workTask?.cancel()
        workTask = nil
        let processedText = text.trim()
        onSearch = false
        switch processedText {
        case "":
            searchingText = nil
            view.dataSource.hideLoadingSection()
            view.dataSource.hidePaginationSection()
            showIntialData()
        case lastSearchedText:
            state = .searched
            searchingText = processedText
            view.dataSource.hideLoadingSection()
            view.dataSource.hidePaginationSection()
            if isPaggingEnabled() {
                let loading = SecondaryLoadingModelView(dependencies: dependencies)
                view.dataSource.showPaginationSection(item: loading)
            }
            state = .searched
            updateHeader()
        default:
            searchingText = processedText
            let loading = SecondaryLoadingModelView(dependencies: dependencies)
            view.dataSource.showLoadingSection(item: loading)
            view.dataSource.hideEmptySection()
            view.dataSource.hidePaginationSection()
            view.dataSource.toTop()
            state = .searching
            updateHeader()
            let task = DispatchWorkItem { [weak self] in
                if let presenter = self {
                    presenter.pagination = nil
                    presenter.searchText(text: processedText)
                }
            }
            workTask = task
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeWaiting, execute: task)
        }
    }
}

// MARK: - LoadStockQuotesSuperUseCaseDelegate

extension StockSearchPresenter: LoadStockQuotesSuperUseCaseDelegate {
    func updateIndex (index: Int) {
        switch index {
        case indexIbex:
            if let ibexQuote = ibexSan?.ibex {
                updateQuote(stockQuote: ibexQuote)
                updateHeader()
            }
        default:
            if index < quotesSearch.count {
                let stockQuote = quotesSearch[index]
                updateQuote(stockQuote: stockQuote)
                view.dataSource.reloadQuoteIndex(index: index)
            }
        }
    }
}

// MARK: - SideMenuCapable

extension StockSearchPresenter: SideMenuCapable {
    var isSideMenuAvailable: Bool {
        return true
    }
}
