import CoreFoundationLib

protocol TransactionsSearchNavigatorProtocol: MenuNavigator {
    func closeSearchAndBack()
    func goToAccountsOTP(delegate: OtpScaAccountPresenterDelegate)
}

protocol TransactionsSearchPresenterProtocol: Presenter, SideMenuCapable, SearchCriteriaDelegate {
    var parameters: [TableModelViewSection] { get }
    var searchHeader: ViewCreatable.Type { get }
    var searchHeaderViewModel: HeaderViewModelType { get }
    var searchDescription: String? { get }
    var shouldHideDefaultSearchButton: Bool { get }
    func cancelChanges()
    func searchWithDefaultParameters()
    func toggleSideMenu()
}

protocol FilterChangeDelegate: class {
    func filterDidChange()
}

class TransactionsSearchPresenter: PrivatePresenter<TransactionsSearchViewController, TransactionsSearchNavigatorProtocol, TransactionsSearchPresenterProtocol> {
    weak var filterDidChangeDelegate: FilterChangeDelegate?

    // MARK: - TrackerScreenProtocol

    override var screenId: String? {
        return searchParameterConfiguration.screenId
    }
    
    override func getTrackParameters() -> [String: String]? {
        return searchParameterConfiguration.getTrackParameters()
    }

    // MARK: -

    private var searchParameterConfiguration: SearchParameterCapable

    init(parametersProvider: SearchParameterCapable, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: TransactionsSearchNavigatorProtocol, filterChangeDelegate: FilterChangeDelegate) {
        self.searchParameterConfiguration = parametersProvider
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
        searchParameterConfiguration.searchInputProvider = view
        self.searchParameterConfiguration.searchCriteriaDelegate = self
        self.filterDidChangeDelegate = filterChangeDelegate
        searchParameterConfiguration.errorDisplayer = self

        self.barButtons = [.menu]
        setBarButtons()
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = dependencies.stringLoader.getString("toolbar_title_search")
    }
}

extension TransactionsSearchPresenter: TransactionsSearchPresenterProtocol {
    var errorHandler: UseCaseErrorHandler? {
        return genericErrorHandler
    }
    
    func startLoading() {
        let type = LoadingViewType.onView(view: view.view, frame: nil, position: .center, controller: view)
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
        showError(keyTitle: keyTitle, keyDesc: keyDesc, phone: nil, completion: completion)
    }
    
    func goToAccountsOTP(delegate: OtpScaAccountPresenterDelegate) {
        navigator.goToAccountsOTP(delegate: delegate)
    }
    
    var shouldHideDefaultSearchButton: Bool {
        return searchParameterConfiguration.shouldHideDefaultSearchButton
    }

    func searchWithDefaultParameters() {
        searchWithCriteria(.byCharacteristics)
    }
    
    func cancelChanges() {
        searchParameterConfiguration.saveTemporalData(false)
    }
    
    var searchDescription: String? {
        return dependencies.stringLoader.getString("search_button_search").text
    }
    
    var searchHeaderViewModel: HeaderViewModelType {
        return searchParameterConfiguration.searchHeaderViewModel
    }
    
    var searchHeader: ViewCreatable.Type {
        return searchParameterConfiguration.searchHeaderCreatable
    }
    
    var parameters: [TableModelViewSection] {
        return searchParameterConfiguration.parameters
    }

    // MARK: - SearchCriteriaDelegate

    func searchWithCriteria(_ criteria: SearchCriteria) {
        searchParameterConfiguration.searchWithCriteria(criteria)
        filterDidChangeDelegate?.filterDidChange()
        navigator.closeSearchAndBack()
    }

    func searchButtonWasTapped(text: String?, criteria: SearchCriteria?) {
        trackSearch(text: text)
        guard let criteria = criteria else {
            searchWithCriteria(.byCharacteristics)
            return
        }
        searchWithCriteria(criteria)
    }
    
    private func trackSearch(text: String?) {
        var parameters = getTrackParameters() ?? [:]
        if text != nil {
            parameters[TrackerDimensions.textSearch] = text ?? ""
        }
        trackEvent(eventId: TrackerPagePrivate.Generic.Action.search.rawValue, parameters: parameters)
    }
}

extension TransactionsSearchPresenter: ErrorDisplayer {
    
    func displayError(text: LocalizedStylableText) {
        let stringLoader = dependencies.stringLoader
        let accept = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept"), does: nil)
        
        Dialog.alert(title: stringLoader.getString("generic_alert_title_errorData"), body: text, withAcceptComponent: accept, withCancelComponent: nil, showsCloseButton: false, source: view)
    }
}

extension TransactionsSearchPresenter: SideMenuCapable {
    
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return true
    }
}
