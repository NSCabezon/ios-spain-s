import Foundation
import CoreFoundationLib

class PersonalAreaVisualOptionsPresenter: PrivatePresenter<PersonalAreaVisualOptionsViewController, PersonalAreaNavigatorProtocol, PersonalAreaVisualOptionsPresenterProtocol>, CardFormatterHelpers {

    // MARK: - TrackerManager

    override var screenId: String? {
        return TrackerPagePrivate.PersonalAreaOptionsVisualizationPg().page
    }

    // MARK: -
    lazy var sessionDataManager: SessionDataManager = {
        let manager = DefaultSessionDataManager(dependenciesResolver: dependencies.dependenciesEngine)
        manager.setDataManagerProcessDelegate(self)
        return manager
    }()
    private var modulesSection: TableModelViewSection!
    private var accountsSection: TableModelViewSection?
    private var notManagedPortfoliosSection: TableModelViewSection?
    private var managedPortfoliosSection: TableModelViewSection?
    private var cardsSection: TableModelViewSection?
    private var depositsSection: TableModelViewSection?
    private var loansSection: TableModelViewSection?
    private var stocksSection: TableModelViewSection?
    private var pensionsSection: TableModelViewSection?
    private var fundsSection: TableModelViewSection?
    private var insuranceSavingsSection: TableModelViewSection?
    private var insuranceProtectionSection: TableModelViewSection?
    
    private var existingSections = [TableModelViewSection]()
    
    private var userId: String?
    private var userPref: UserPref?
    private var isPb: Bool?
    private var _viewPositions = [CoachmarkIdentifier: IntermediateRect]()
    var coachmarksToBeSet = [CoachmarkIdentifier]()

    override func loadViewData() {
        super.loadViewData()
        
        view.styledTitle = stringLoader.getString("toolbar_title_displayOptions")
        
        UseCaseWrapper(with: useCaseProvider.getPGDataUseCase(),
                       useCaseHandler: useCaseHandler,
                       errorHandler: genericErrorHandler,
                       onSuccess: { [weak self] result in
                        self?.userId = result.globalPosition.userId
                        self?.userPref = result.userPref
                        self?.isPb = result.globalPosition.isPb
                        self?.makeSections(withGlobalPosition: result.globalPosition)
        })
    }
    
    private func makeSections(withGlobalPosition globalPosition: GlobalPositionWrapper) {
        existingSections = [TableModelViewSection]()
        existingSections.append(makeHeader())
        
        modulesSection = makeInitialSection()
        
        accountsSection = makeAccountsSection(accounts: globalPosition.accounts.get(ordered: true))
        notManagedPortfoliosSection = makePortfoliosSection(portfolios: globalPosition.notManagedPortfolios.get(ordered: true), managed: false)
        managedPortfoliosSection = makePortfoliosSection(portfolios: globalPosition.managedPortfolios.get(ordered: true), managed: true)
        cardsSection = makeCardsSection(cards: globalPosition.cards.get(ordered: true))
        depositsSection = makeDepositsSection(deposits: globalPosition.deposits.get(ordered: true))
        loansSection = makeLoansSection(loans: globalPosition.loans.get(ordered: true))
        stocksSection = makeStocksSection(stocks: globalPosition.stockAccounts.get(ordered: true))
        pensionsSection = makePensionsSection(pensions: globalPosition.pensions.get(ordered: true))
        fundsSection = makeFundsSection(funds: globalPosition.funds.get(ordered: true))
        insuranceSavingsSection = makeSavingsInsurancesSection(insurances: globalPosition.insuranceSavings.get(ordered: true))
        insuranceProtectionSection = makeProtectionInsurancesSection(insurances: globalPosition.insuranceProtection.get(ordered: true))
        
        let sections: [TableModelViewSection?]
        if isPb == true {
            sections = [modulesSection,
                        accountsSection,
                        notManagedPortfoliosSection,
                        managedPortfoliosSection,
                        cardsSection,
                        depositsSection,
                        loansSection,
                        stocksSection,
                        pensionsSection,
                        fundsSection,
                        insuranceSavingsSection,
                        insuranceProtectionSection]
        } else {
            sections = [modulesSection,
                        accountsSection,
                        cardsSection,
                        stocksSection,
                        loansSection,
                        depositsSection,
                        pensionsSection,
                        fundsSection,
                        notManagedPortfoliosSection,
                        managedPortfoliosSection,
                        insuranceSavingsSection,
                        insuranceProtectionSection]
        }
        sections.compactMap { $0 }.forEach { existingSections.append($0) }
        
        view.addSections(existingSections) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.view.findCoachmarks(neededIds: strongSelf.neededIdentifiers) { [weak self] coachmarks in
                self?.setCoachmarks(coachmarks: coachmarks, isForcedCoachmark: false)
            }
        }
    }
    
    private func makeHeader() -> TableModelViewSection {
        let headerSection = TableModelViewSection()
        let headerViewModel = GenericOperativeHeaderTitleAndDescriptionViewModel(title: stringLoader.getString("displayOptions_title_seeOrder"), description: stringLoader.getString("displayOptions_text_seeOrder"))
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeHeaderTitleAndDescriptionView.self, dependencies: dependencies)
        
        headerSection.add(item: headerCell)
        
        return headerSection
    }
    
    private func makeInitialSection() -> TableModelViewSection {
        let initialSection = TableModelViewSection()
        guard let userPref = userPref else {
            return initialSection
        }
        initialSection.setHeader(modelViewHeader: SettingsTitleHeaderViewModel(title: stringLoader.getString("displayOptions_title_initialModules")))
        let itemMoneyVisible = userPref.userPrefDTO.pgUserPrefDTO.yourMoneyModule.isVisible
        let itemMoney = DraggableBasicViewModel(itemIdentifier: PGModuleDTO.Constants.yourMoneyModule, title: stringLoader.getString("displayOptions_label_money").text, subtitle: nil, switchState: itemMoneyVisible, isDraggable: false, change: { [weak self] active in
            if active {
                self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.activateYourMoney.rawValue, parameters: [:])
            } else {
                self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.deactivateYourMoney.rawValue, parameters: [:])
            }
            }, dependencies: dependencies)
        itemMoney.switchCoachmarkId = .visualizationOptions
        initialSection.add(item: itemMoney)
        
        let itemExpensesVisible = userPref.userPrefDTO.pgUserPrefDTO.pfmModule.isVisible
        let itemExpenses = DraggableBasicViewModel(itemIdentifier: PGModuleDTO.Constants.pfmModule, title: stringLoader.getString("displayOptions_label_expenses").text, subtitle: nil, switchState: itemExpensesVisible, isDraggable: false, change: { [weak self] active in
            if active {
                self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.activatePersonalExpenses.rawValue, parameters: [:])
            } else {
                self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.deactivatePersonalExpenses.rawValue, parameters: [:])
            }
            }, dependencies: dependencies)
        initialSection.add(item: itemExpenses)
        
        return initialSection
    }
    
    private func makeAccountsSection(accounts: [Account]) -> TableModelViewSection? {
        guard accounts.count >= 1 else {
            return nil
        }
        let section = TableModelViewSection()
        section.setHeader(modelViewHeader: SettingsTitleHeaderViewModel(title: stringLoader.getString("pgBasket_title_accounts")))
        for account in accounts {
            let item = DraggableBasicViewModel(itemIdentifier: account.productIdentifier, title: account.getAliasCamelCase(), subtitle: account.getIBANShort(), switchState: account.isVisible(), change: { [weak self] active in
                if active {
                    self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.activateAccounts.rawValue, parameters: [:])
                } else {
                    self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.deactivateAccounts.rawValue, parameters: [:])
                }
            }, dependencies: dependencies)
            section.add(item: item)
        }
        
        return section
    }
    
    private func makePortfoliosSection(portfolios: [Portfolio], managed: Bool) -> TableModelViewSection? {
        guard portfolios.count >= 1 else {
            return nil
        }
        let section = TableModelViewSection()
        let title = managed ? stringLoader.getString("pgBasket_title_portfolioManaged") : stringLoader.getString("pgBasket_title_portfolioNotManaged")
        section.setHeader(modelViewHeader: SettingsTitleHeaderViewModel(title: title))
        for portfolio in portfolios {
            let item = DraggableBasicViewModel(itemIdentifier: portfolio.productIdentifier, title: portfolio.getAliasCamelCase(), subtitle: portfolio.getDetailUI(), switchState: portfolio.isVisible(), change: nil, dependencies: dependencies)
            section.add(item: item)
        }
        
        return section
    }
    
    private func makeCardsSection(cards: [Card]) -> TableModelViewSection? {
        guard cards.count >= 1 else {
            return nil
        }
        let section = TableModelViewSection()
        section.setHeader(modelViewHeader: SettingsTitleHeaderViewModel(title: stringLoader.getString("pgBasket_title_cards")))
        cards.forEach { (card) in
            let item = DraggableBasicViewModel(itemIdentifier: card.productIdentifier,
                                               title: card.getAliasCamelCase(),
                                               subtitle: getStyledSubNameFor(card, stringLoader: stringLoader).text,
                                               switchState: card.isVisible(),
                                               imageURL: card.buildImageRelativeUrl(true),
                                               isActive: card.isActive && !card.isTemporallyOff && !card.isContractBlocked, change: { [weak self] active in
                                                if active {
                                                    self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.activateCards.rawValue, parameters: [:])
                                                } else {
                                                    self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.deactivateCards.rawValue, parameters: [:])
                                                }
                },
                                               dependencies: dependencies)
            section.add(item: item)
        }

        return section
    }
    
    private func makeDepositsSection(deposits: [Deposit]) -> TableModelViewSection? {
        guard deposits.count >= 1 else {
            return nil
        }
        let section = TableModelViewSection()
        section.setHeader(modelViewHeader: SettingsTitleHeaderViewModel(title: stringLoader.getString("pgBasket_title_deposits")))
        for deposit in deposits {
            var subtitle = ""
            if let detailUI = deposit.getDetailUI(), detailUI.count > 4 {
                subtitle = "***\(detailUI.substring(detailUI.count - 4) ?? "")"
            }
            let item = DraggableBasicViewModel(itemIdentifier: deposit.productIdentifier, title: deposit.getAliasCamelCase(), subtitle: subtitle, switchState: deposit.isVisible(), change: { [weak self] active in
                if active {
                    self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.activateDeposits.rawValue, parameters: [:])
                } else {
                    self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.deactivateDeposits.rawValue, parameters: [:])
                }
                }, dependencies: dependencies)
            section.add(item: item)
        }
        
        return section
    }
    
    private func makeLoansSection(loans: [Loan]) -> TableModelViewSection? {
        guard loans.count >= 1 else {
            return nil
        }
        let section = TableModelViewSection()
        section.setHeader(modelViewHeader: SettingsTitleHeaderViewModel(title: stringLoader.getString("pgBasket_title_loans")))
        for loan in loans {
            let item = DraggableBasicViewModel(itemIdentifier: loan.productIdentifier, title: loan.getAliasCamelCase(), subtitle: loan.getDetailUI(), switchState: loan.isVisible(), change: { [weak self] active in
                if active {
                    self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.activateLoans.rawValue, parameters: [:])
                } else {
                    self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.deactivateLoans.rawValue, parameters: [:])
                }
                }, dependencies: dependencies)
            section.add(item: item)
        }
        
        return section
    }
    
    private func makeStocksSection(stocks: [StockAccount]) -> TableModelViewSection? {
        guard stocks.count >= 1 else {
            return nil
        }
        let section = TableModelViewSection()
        section.setHeader(modelViewHeader: SettingsTitleHeaderViewModel(title: stringLoader.getString("pgBasket_title_stocks")))
        for stock in stocks {
            var subtitle = ""
            if stock.getDetailUI().count > 4 {
                subtitle = "***\(stock.getDetailUI().substring(stock.getDetailUI().count - 4) ?? "")"
            }
            let item = DraggableBasicViewModel(itemIdentifier: stock.productIdentifier, title: stock.getAliasCamelCase(), subtitle: subtitle, switchState: stock.isVisible(), change: { [weak self] active in
                if active {
                    self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.activateStocks.rawValue, parameters: [:])
                } else {
                    self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.deactivateStocks.rawValue, parameters: [:])
                }
                }, dependencies: dependencies)
            section.add(item: item)
        }
        
        return section
    }
    
    private func makePensionsSection(pensions: [Pension]) -> TableModelViewSection? {
        guard pensions.count >= 1 else {
            return nil
        }
        let section = TableModelViewSection()
        section.setHeader(modelViewHeader: SettingsTitleHeaderViewModel(title: stringLoader.getString("pgBasket_title_plans")))
        for pension in pensions {
            var subtitle = ""
            if pension.getDetailUI().count > 4 {
                subtitle = "***\(pension.getDetailUI().substring(pension.getDetailUI().count - 4) ?? "")"
            }
            let item = DraggableBasicViewModel(itemIdentifier: pension.productIdentifier, title: pension.getAliasCamelCase(), subtitle: subtitle, switchState: pension.isVisible(), change: { [weak self] active in
                if active {
                    self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.activatePensions.rawValue, parameters: [:])
                } else {
                    self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.deactivatePensions.rawValue, parameters: [:])
                }
                }, dependencies: dependencies)
            section.add(item: item)
        }
        
        return section
    }
    
    private func makeFundsSection(funds: [Fund]) -> TableModelViewSection? {
        guard funds.count >= 1 else {
            return nil
        }
        let section = TableModelViewSection()
        section.setHeader(modelViewHeader: SettingsTitleHeaderViewModel(title: stringLoader.getString("pgBasket_title_funds")))
        for fund in funds {
            var subtitle = ""
            if let detail = fund.getDetailUI(), detail.count > 4 {
                subtitle = "***\(detail.substring(detail.count - 4) ?? "")"
            }
            let item = DraggableBasicViewModel(itemIdentifier: fund.productIdentifier, title: fund.getAliasCamelCase(), subtitle: subtitle, switchState: fund.isVisible(), change: { [weak self] active in
                if active {
                    self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.activateFunds.rawValue, parameters: [:])
                } else {
                    self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.deactivateFunds.rawValue, parameters: [:])
                }
                }, dependencies: dependencies)
            section.add(item: item)
        }
        
        return section
    }
    
    private func makeSavingsInsurancesSection(insurances: [InsuranceSaving]) -> TableModelViewSection? {
        guard insurances.count >= 1 else {
            return nil
        }
        let section = TableModelViewSection()
        section.setHeader(modelViewHeader: SettingsTitleHeaderViewModel(title: stringLoader.getString("pgBasket_title_insuranceSaving")))
        for insurance in insurances {
            let item = DraggableBasicViewModel(itemIdentifier: insurance.productIdentifier, title: insurance.getAliasCamelCase(), subtitle: insurance.getDetailUI(), switchState: insurance.isVisible(), change: { [weak self] active in
                if active {
                    self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.activateInsuranceSaving.rawValue, parameters: [:])
                } else {
                    self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.deactivateInsuranceSaving.rawValue, parameters: [:])
                }
                }, dependencies: dependencies)
            section.add(item: item)
        }
        
        return section
    }
    
    private func makeProtectionInsurancesSection(insurances: [InsuranceProtection]) -> TableModelViewSection? {
        guard insurances.count >= 1 else {
            return nil
        }
        let section = TableModelViewSection()
        section.setHeader(modelViewHeader: SettingsTitleHeaderViewModel(title: stringLoader.getString("pgBasket_title_insurance")))
        for insurance in insurances {
            let item = DraggableBasicViewModel(itemIdentifier: insurance.productIdentifier, title: insurance.getAliasCamelCase(), subtitle: insurance.getDetailUI(), switchState: insurance.isVisible(), change: { [weak self] active in
                if active {
                    self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.activateInsurances.rawValue, parameters: [:])
                } else {
                    self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.deactivateInsurances.rawValue, parameters: [:])
                }
                }, dependencies: dependencies)
            section.add(item: item)
        }
        
        return section
    }
}

extension PersonalAreaVisualOptionsPresenter: PersonalAreaVisualOptionsPresenterProtocol {
    var saveTitle: LocalizedStylableText {
        return stringLoader.getString("displayOptions_button_saveChanges")
    }
    
    enum UserPrefUpdate {
        case success
        case error
    }
    
    func saveConfiguration() {
        self.view.disableUserInteraction()
        startGlobalLoading { [weak self] in
            self?.updateUserPrefs { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.reloadGlobalPosition()
                case .error:
                    self.hideGlobalLoading { [weak self] in
                        self?.showError(keyDesc: "generic_error_txt")
                    }
                }
            }
        }
    }
    
    private func updateUserPrefs(completion: @escaping (UserPrefUpdate) -> Void) {
        
        func updateVisualization(_ userPref: UserPref, modules: [UserVisualizationModule], boxes: [UserVisualizationBox], completion: @escaping (UserPref) -> Void) {
            let useCaseInput = UpdateUserVisualizationsUseCaseInput(userPref: userPref, modules: modules, boxes: boxes)
            let useCase = useCaseProvider.updateUserVisualizationsUseCase(input: useCaseInput)
            UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, onSuccess: { result in
                completion(result.userPref)
            })
        }
        
        func savePreferences(_ userPref: UserPref, completion: @escaping (UserPrefUpdate) -> Void) {
            let updateInput = UpdatePGUserPrefUseCaseInput(userPref: userPref)
            let updateUseCase = useCaseProvider.getUpdatePGUserPrefUseCase(input: updateInput)
            UseCaseWrapper(with: updateUseCase, useCaseHandler: useCaseHandler, errorHandler: nil, onSuccess: { _ in
                completion(.success)
            }, onError: { error in
                completion(.error)
            })
        }
        
        guard let userPref = userPref else {
            completion(.error)
            return
        }
        
        var modules = [UserVisualizationModule]()
        var boxes = [UserVisualizationBox]()
        
        for section in existingSections {
            if section == modulesSection, let items = section.items as? [DraggableBasicViewModel] {
                modules = items.map { UserVisualizationModule(itemIdentifier: $0.itemIdentifier, isVisible: $0.switchState) }
            } else if let items = section.items as? [DraggableBasicViewModel] {
                let boxItems = items.enumerated().map { UserVisualizationItem(itemIdentifier: $1.itemIdentifier, isVisible: $1.switchState) }
                let box: VisualizationBoxType?
                switch section {
                case accountsSection:
                    box = .accounts
                case notManagedPortfoliosSection:
                    box = .notManagedPortfolios
                case managedPortfoliosSection:
                    box = .managedPortfolios
                case cardsSection:
                    box = .cards
                case depositsSection:
                    box = .deposits
                case loansSection:
                    box = .loans
                case stocksSection:
                    box = .stocks
                case pensionsSection:
                    box = .pensions
                case fundsSection:
                    box = .funds
                case insuranceSavingsSection:
                    box = .insuranceSavings
                case insuranceProtectionSection:
                    box = .insuranceProtection
                default:
                    box = nil
                }
                
                guard let boxType = box else {
                    completion(.error)
                    return
                }
                
                boxes += [UserVisualizationBox(type: boxType, items: boxItems)]
            }
        }
        
        UseCaseWrapper(with: useCaseProvider.getPGDataUseCase(),
                       useCaseHandler: useCaseHandler,
                       errorHandler: genericErrorHandler,
                       onSuccess: { result in
                let userPref = result.userPref ?? userPref
                updateVisualization(userPref, modules: modules, boxes: boxes) { updated in
                    savePreferences(updated, completion: { result in
                        completion(result)
                    })
                }
        })
    }
    
}

extension PersonalAreaVisualOptionsPresenter: Presenter {
}

extension PersonalAreaVisualOptionsPresenter: SideMenuCapable {
    
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension PersonalAreaVisualOptionsPresenter: SessionDataManagerProcessDelegate {}
extension PersonalAreaVisualOptionsPresenter: PersonalAreaPGReloadableCapable {
    func didFinishReloadPersonalArea() {
      self.view.enableUserInteraction()
    }
}

extension PersonalAreaVisualOptionsPresenter: CoachmarkPresenter {
    
    var viewPositions: [CoachmarkIdentifier: IntermediateRect] {
        get {
            return self._viewPositions
        }
        set {
            if newValue.count == 0 {
                self._viewPositions = [CoachmarkIdentifier: IntermediateRect]()
            } else {
                for (key, value) in newValue {
                    self._viewPositions[key] = value
                }
            }
        }
    }
    
    func resetCoachmarks() {
        self.viewPositions = [CoachmarkIdentifier: IntermediateRect]()
        self.coachmarksToBeSet = [CoachmarkIdentifier]()
    }
    
    func setCoachmarks(coachmarks: [CoachmarkIdentifier: IntermediateRect], isForcedCoachmark: Bool) {
        
        let callback: () -> Void = {  [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.viewPositions.count == strongSelf.neededIdentifiers.count && strongSelf.viewPositions.filter({$0.value != IntermediateRect.zero}).count > 0 {
                UseCaseWrapper(with: strongSelf.useCaseProvider.setCoachmarkSeen(input: SetCoachmarkSeenInput(coachmarkIds: strongSelf.coachmarksToBeSet)), useCaseHandler: strongSelf.useCaseHandler, errorHandler: strongSelf.genericErrorHandler)
                Coachmark.present(source: strongSelf.view, presenter: strongSelf)
                strongSelf.resetCoachmarks()
            }
        }
        
        if coachmarks.count > 0 {
            for coachmark in coachmarks {
                UseCaseWrapper(with: useCaseProvider.isCoachmarkSeen(input: GetCoachmarkStatusUseCaseInput(coachmarkId: coachmark.key)), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] result in
                    
                    guard let strongSelf = self else { return }
                    
                    if !result.status && coachmark.value != IntermediateRect.zero {
                        //NO SE HA PINTADO
                        if !strongSelf.coachmarksToBeSet.contains(coachmark.key) {
                            strongSelf.coachmarksToBeSet.append(coachmark.key)
                        }
                        strongSelf.viewPositions[coachmark.key] = coachmark.value
                    } else {
                        strongSelf.viewPositions[coachmark.key] = IntermediateRect.zero
                    }
                    callback()
                })
            }
            
        } else {
            callback()
        }
    }
    
    var neededIdentifiers: [CoachmarkIdentifier] {
        return [.visualizationOptions]
    }
    
    var texts: [CoachmarkIdentifier: String] {
        var output = [CoachmarkIdentifier: String]()
        output[.visualizationOptions] = stringLoader.getString("coachmarks_label_displayOptions").text
        return output
    }
}

extension PersonalAreaVisualOptionsPresenter: DraggableTableViewDataSourceDelegate {
    func didMoveItem(item: TableModelViewProtocol) {
    }
    
    func moveInSection(section: TableModelViewSection) {
        switch section {
        case accountsSection:
            trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.moveAccounts.rawValue, parameters: [:])
        case cardsSection:
            trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.movecards.rawValue, parameters: [:])
        case stocksSection:
            trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.moveStocks.rawValue, parameters: [:])
        case loansSection:
            trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.moveLoans.rawValue, parameters: [:])
        case depositsSection:
            trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.moveDeposits.rawValue, parameters: [:])
        case pensionsSection:
            trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.movePensions.rawValue, parameters: [:])
        case fundsSection:
            trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.moveFunds.rawValue, parameters: [:])
        case insuranceProtectionSection:
            trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.moveInsurances.rawValue, parameters: [:])
        case insuranceSavingsSection:
            trackEvent(eventId: TrackerPagePrivate.PersonalAreaOptionsVisualizationPg.Action.moveInsuranceSaving.rawValue, parameters: [:])
        default:
            break
        }
    }
}
