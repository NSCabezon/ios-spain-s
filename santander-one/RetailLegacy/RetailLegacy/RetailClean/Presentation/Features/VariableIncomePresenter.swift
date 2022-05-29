import CoreDomain

class VariableIncomePresenter: PrivatePresenter<VariableIncomeViewController, PrivateHomeNavigator & PrivateHomeNavigatorSideMenu, VariableIncomePresenterProtocol> {
    
    private var globalPosition: GlobalPositionWrapper!
    private var userPref: UserPref?
    private var filter: OwnershipProfile?
    
    private var portfoliosManagedVariableIncomeSection: ProductModelViewSection?
    private var portfoliosNotManagedVariableIncomeSection: ProductModelViewSection?
    
    override func loadViewData() {
        super.loadViewData()
        
        view.styledTitle = stringLoader.getString("toolbar_title_variableIncome")
        
        loadData()
    }
    
    private func loadData() {
        UseCaseWrapper(with: useCaseProvider.getPGDataUseCase(),
                       useCaseHandler: useCaseHandler,
                       errorHandler: genericErrorHandler,
                       onSuccess: { [weak self] result in
                        guard let strongSelf = self else { return }
                        strongSelf.fillViews(result.globalPosition, result.userPref)
        })
    }
    
    private func fillViews(_  globalPosition: GlobalPositionWrapper, _ userPref: UserPref?) {
        self.userPref = userPref
        self.globalPosition = globalPosition
        
        requestInterventionType()
    }
    
    private func requestInterventionType() {
        UseCaseWrapper(with: useCaseProvider.getPGInterventionTypeUseCase(),
                       useCaseHandler: useCaseHandler,
                       errorHandler: genericErrorHandler,
                       onSuccess: { [weak self] result in
                        guard let strongSelf = self else { return }
                        strongSelf.updateFor(ownershipProfile: result.profile)
        })
    }
    
    private func updateFor(ownershipProfile: OwnershipProfile) {
        filter = ownershipProfile
        view.removeAllSections()
        var result = [TableModelViewSection]()
        
        result += makeProducts()
        view.addSections(result)
    }
    
    private func makeProducts() -> [TableModelViewSection] {
        if globalPosition.isPb {
            return makeSectionsPb()
        } else {
            return makeSections()
        }
    }
    
    public func makeSectionsPb() -> [TableModelViewSection] {
        var sections = [TableModelViewSection?]()
        sections.append(makePortfoliosNotManagedSection())
        sections.append(makePortfoliosManagedSection())
        if sections.compactMap({$0}).isEmpty {
            sections.append(makeEmptyViewSection())
        }
        return sections.compactMap {$0}
    }
    
    public func makeSections() -> [TableModelViewSection] {
        var sections = [TableModelViewSection?]()
        sections.append(makePortfoliosNotManagedSection())
        sections.append(makePortfoliosManagedSection())
        
        return sections.compactMap({$0})
    }
    
    private func makePortfoliosManagedSection() -> TableModelViewSection? {
        let stockAccounts = globalPosition.managedRVStockAccounts.getVisibles(filter)
        guard !stockAccounts.isEmpty else {
            return nil
        }
        portfoliosManagedVariableIncomeSection = ProductModelViewSection()
        portfoliosManagedVariableIncomeSection?.setHeader(modelViewHeader: PortfolioManagedVariableIncomeModelViewHeader(globalPosition, filter, userPref, stringLoader, useCaseProvider, useCaseHandler, false))
        if let open = userPref?.isPortfolioManagedVariableIncomeBoxOpen() {
            portfoliosManagedVariableIncomeSection?.isCollapsed = !open
        }
        stockAccounts.forEach { portfoliosManagedVariableIncomeSection?.add(item: StockAccountModelView($0, dependencies)) }
        guard let section = portfoliosManagedVariableIncomeSection else {
            return nil
        }
        
        return section
    }
    
    private func makePortfoliosNotManagedSection() -> TableModelViewSection? {
        let stockAccounts = globalPosition.notManagedRVStockAccounts.getVisibles(filter)
        guard !stockAccounts.isEmpty else {
            return nil
        }
        portfoliosNotManagedVariableIncomeSection = ProductModelViewSection()
        portfoliosNotManagedVariableIncomeSection?.setHeader(modelViewHeader: PortfolioNotManagedVariableIncomeModelViewHeader(globalPosition, filter, userPref, stringLoader, useCaseProvider, useCaseHandler, false))
        if let open = userPref?.isPortfolioNotManagedVariableIncomeBoxOpen() {
            portfoliosNotManagedVariableIncomeSection?.isCollapsed = !open
        }
        stockAccounts.forEach { portfoliosNotManagedVariableIncomeSection?.add(item: StockAccountModelView($0, dependencies)) }
        guard let section = portfoliosNotManagedVariableIncomeSection else {
            return nil
        }
        
        return section
    }
    
    func makeEmptyViewSection() -> TableModelViewSection {
        let emptyViewSection = EmptyViewSection()
        emptyViewSection.add(item: EmptyViewModelView(stringLoader.getString("pg_label_emptyView"), dependencies))
        return emptyViewSection
    }
    
    func filter(ownershipProfile: OwnershipProfile) {
        requestInterventionType()
    }
    
    func updateTable() {
        view.updateTable()
    }
    
    func updateTableAndScroll(to section: TableModelViewSection, toTop: Bool) {
        view.updateTableAndScrollTo(section: section, toTop: toTop)
    }
    
    func didSelect(section: TableModelViewSection, indexRow: Int) {
        let item = section.items[indexRow]
        if let model = item as? ProductBaseModelViewProtocol, let product = model.getProduct() {
            if let stockAccount = product as? StockAccount, let stockAccountType = stockAccount.stockAccountType {
                switch stockAccountType {
                case .RVManaged:
                    navigator.presentOverCurrentController(selectedProduct: product, productHome: .managedRVPortfolios)
                case .RVNotManaged:
                    navigator.presentOverCurrentController(selectedProduct: product, productHome: .notManagedRVPortfolios)
                default:
                    navigator.presentOverCurrentController(selectedProduct: product, productHome: .stocks)
                }
            }
        }
    }
}

// MARK: - Extensions

extension VariableIncomePresenter: VariableIncomePresenterProtocol {    
}

extension VariableIncomePresenter: SideMenuCapable {
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return true
    }
}
