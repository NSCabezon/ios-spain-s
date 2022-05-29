// swiftlint:disable type_body_length
//
//  PGClassicPresenter.swift
//  GlobalPosition
//
//  Created by alvola on 28/10/2019.
//

import UI
import CoreFoundationLib
import CoreDomain

protocol PGClassicPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: PGClassicViewProtocol? { get set }
    var dataManager: PGDataManagerProtocol? { get set }
    func viewDidLoad()
    func viewDidAppear()
    func viewWillAppear()
    func viewDidDisappear()
    func mailDidPress()
    func searchDidPress()
    func drawerDidPress()
    func usernameDidPress()
    func moreOptionPress()
    func logoDidPress()
    func setController(_ controller: PGClassicTableViewController)
    func reload()
    func didSelectWhatsNew()
    func didSelectOffer(offer: OfferEntity)
}

final class PGClassicPresenter: PGClassicPresenterProtocol {
    private let resolver: DependenciesResolver
    var dependenciesResolver: DependenciesResolver {
        return self.resolver
    }
    internal weak var view: PGClassicViewProtocol?
    internal weak var dataManager: PGDataManagerProtocol?
    weak var delegate: GlobalPositionModuleCoordinatorDelegate?
    weak var pullOffersDelegate: PTDeeplinkVerifierProtocol? {
        return resolver.resolve(forOptionalType: PTDeeplinkVerifierProtocol.self)
    }
    private lazy var currentBalanceItem = CurrentBalanceCarouselItem()
    private lazy var expensesItem = ExpensesCarouselItem()
    private var controller: PGClassicTableViewController? {
        didSet {
            controller?.delegate = self
        }
    }
    private var classicWrapper: ClassicGlobalPositionWrapperProtocol?
    private var sectionsToUpdate: Set<Int> = []
    private var rowsToUpdate: [IndexPath] = []
    internal var availableActions: [GpOperativesViewModel] = []
    private var frequentOperativeOptionSelected: PGFrequentOperativeOptionProtocol?
    var pgCoordinator: PGClassicCoordinator {
        return resolver.resolve(for: PGClassicCoordinator.self)
    }
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity] = [:]
    private var notPGValuesOnAppear: Bool = true
    private var checkAnalysisZone: GetCheckAnalysisUseCase {
        return self.resolver.resolve(for: GetCheckAnalysisUseCase.self)
    }
    private var checkingAnalysisZone: Bool = false
    private var useCaseHandler: UseCaseHandler {
        return self.resolver.resolve(for: UseCaseHandler.self)
    }
    
    private var stringLoader: StringLoader {
        return self.resolver.resolve(for: StringLoader.self)
    }
    
    private var baseURLProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    private var coordinator: GlobalPositionModuleCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: GlobalPositionModuleCoordinatorProtocol.self)
    }
    
    private var doubleTapping: Bool = false
    
    private var discreteModeActivated: Bool?
    private var enableInsuranceDetail: Bool = false
    // MARK: Favourite Carousel
    private var isFavouriteCarouselEnabled: Bool = false
    private var cacheDefaultPills: [OnePayCollectionInfo] = []
    private var localAppConfig: LocalAppConfig {
        self.resolver.resolve(for: LocalAppConfig.self)
    }
    private var isBigWhatsNewVisible: Bool = false
    private var monthlyBalance: [MonthlyBalanceRepresentable]?
    private var portfolioWebViewConfigUseCase: GetPortfolioWebViewConfigurationUseCase {
        return self.resolver.resolve(for: GetPortfolioWebViewConfigurationUseCase.self)
    }
    
    init(resolver: DependenciesResolver) {
        self.resolver = resolver
        let globalPositionReloadEngine = self.resolver.resolve(for: GlobalPositionReloadEngine.self)
        globalPositionReloadEngine.removeList()
        globalPositionReloadEngine.add(self)
        self.classicWrapper = resolver.resolve(for: ClassicGlobalPositionWrapperProtocol.self)
        self.delegate = resolver.resolve(for: GlobalPositionModuleCoordinatorDelegate.self)
    }
    
    func viewDidLoad() {
        getIsSearchEnabled()
        self.delegate?.globalPositionDidLoad()
        dataManager?.getPGValues({ [weak self] response in
            guard let self = self else { return }
            self.enableInsuranceDetail = response.enableInsuranceDetail
            self.pullOfferCandidates = response.pullOfferCandidates
            self.setViewInfo(response)
            self.classicWrapper?.refreshUserPref(response)
            self.view?.setUserName(self.classicWrapper?.configuration?.userName ?? "", birthDay: self.isBirthday())
            self.setupCurrentBalance(balanceValue: response.totalFinance, financingValue: response.financingTotal, discreteMode: response.userPref?.isDiscretModeActivated() ?? false, insuranceEnabled: response.isInsuranceEnabled)
            self.expensesItem.blurred = response.userPref?.isDiscretModeActivated() ?? false
            self.getMovementsOfAccounts(response.visibleAccounts)
            self.getMovementsOfCards(response.cards)
            self.setupExpensesItemActions()
            self.configureFavouriteCarousel(response)
            self.isBigWhatsNewVisible = response.userPref?.isWhatsNewBigBubbleVisible() ?? false
            let isHiddenCarousel = !(response.userPref?.isChartModeActivated() ?? false) || self.carouselData == nil
            self.view?.setCarouselData(self.carouselData, isHiddenCarousel: isHiddenCarousel, animated: true, isBigWhatsNewVisible: self.isBigWhatsNewVisible)
        }, failure: { _ in })
        trackScreen()
    }
    
    func viewWillAppear() {
        if self.notPGValuesOnAppear {
            self.notPGValuesOnAppear = false
        } else {
            dataManager?.getPGValues({ [weak self] response in
                guard let self = self else { return }
                self.pullOfferCandidates = response.pullOfferCandidates
                self.classicWrapper?.refreshUserPref(response)
                self.view?.setUserName(self.classicWrapper?.configuration?.userName ?? "", birthDay: self.isBirthday())
                self.getMovementsOfAccounts(response.visibleAccounts)
                self.getMovementsOfCards(response.cards)
            }, failure: { _ in })
        }
        callBannerLimitsIfNeeded()
    }
    
    func viewDidAppear() {
        self.delegate?.globalPositionDidAppear()
        self.checkFrequentOperativeOptionSelected()
        self.view?.updatePendingSolicitudes()
    }
    
    func viewDidDisappear() {
        self.saveDiscreteModeState()
        self.delegate?.globalPositionDidDisappear()
    }
    
    func mailDidPress() { delegate?.didSelectMail() }
    func searchDidPress() { delegate?.didSelectSearch() }
    func drawerDidPress() { delegate?.didSelectMenu() }
    func usernameDidPress() {
        guard let offer = self.classicWrapper?.getOffer(forLocation: GlobalPositionPullOffers.happyBirthday) else { return }
        self.delegate?.didSelectOffer(offer.entity)
    }
    
    func menuComponents(_ completion: @escaping ([MenuTextModel: String]) -> Void) {
        let menuText: MenuTextWrapperProtocol = self.resolver.resolve()
        menuText.get(completion: completion)
    }
    
    func setController(_ controller: PGClassicTableViewController) { self.controller = controller }
    
    private func setupCurrentBalance(balanceValue: Decimal?, financingValue: Decimal?, discreteMode: Bool, insuranceEnabled: Bool) {
        let balanceAmount: AmountEntity? = balanceValue != nil ? AmountEntity(value: balanceValue!): nil
        let financingAmount: AmountEntity? = financingValue != nil ? AmountEntity(value: financingValue!): nil
        let tooltipText = insuranceEnabled ? "tooltip_text_pgMoneyFinancing" : "tooltip_text_pgMoneyFinancingWithoutInsurance"
        currentBalanceItem.setDiscreteMode(discreteMode)
        currentBalanceItem.setFinantialStatusInfo(totalBalance: balanceAmount, financingTotal: financingAmount, tooltipText: tooltipText)
        currentBalanceItem.action = { [weak self] _ in
            self?.didSelectBalance()
        }
        currentBalanceItem.setGraphHidden(false)
        expensesItem.setFinantialStatusInfo(totalBalance: balanceAmount, financingTotal: financingAmount, tooltipText: tooltipText)
    }
    
    private func callBannerLimitsIfNeeded() {
        dataManager?.getLoanBannerLimits { [weak self] bannerEntity in
            guard let self = self else { return }
            if let loanBanner = bannerEntity {
                self.classicWrapper?.setLoanBannerLimits(limits: loanBanner)
                self.callFavouriteCarouselIfNeeded()
                self.update()
            }
        }
    }
    
    private func setupExpenses(animated: Bool) {
        if let balance = self.monthlyBalance {
            displayMonthlyExpenses(balance, animated: animated, showPredictiveExpense: true)
        }
    }
    
    private var carouselData: [CarouselClassicItemViewModelType]? {
        return [expensesItem]
    }
    
    private func getIsSearchEnabled() {
        dataManager?.getIsSearchEnabled(with: resolver) { [weak self] response in
            self?.view?.isSearchEnabled = response
        }
    }
    
    func didSelectBalance() { delegate?.didSelectBalance() }
    
    // MARK: - privateMethods
    
    private func update() {
        refreshInfo()
        controller?.reloadAllTable()
    }
    
    private func refreshInfo() {
        if let wrapper = classicWrapper {
            controller?.cellsInfo = wrapper.toCellsDictionary()
            view?.shouldAddInsetToSafeArea(wrapper.isOnePayCarouselEnabled())
        }
    }
    
    private func setViewInfo(_ info: GetPGUseCaseOkOutput) {
        classicWrapper?.setGPValues(info, filter: dataManager?.getInterventionFilter() ?? .all)
        update()
        getOtherOperatives(info.frequentOperatives)
        controller?.discreteModeEnabled = info.userPref?.isDiscretModeActivated() ?? false
        self.view?.updateSantanderLogoAccessibility(discretMode: info.userPref?.isDiscretModeActivated() ?? false)
        self.view?.setVisibilityBalanceCarousel(info.userPref?.isChartModeActivated() == true)
        self.loadMonthlyBalance(animated: false)
        setSantanderLogo(info)
        view?.setAvailableActions(Array(availableActions.prefix(4)))
        expensesItem.setDiscreteMode(info.userPref?.isDiscretModeActivated() ?? false)
    }
    
    private func setSantanderLogo(_ info: GetPGUseCaseOkOutput) {
        if let userSegmentDelegate: UserSegmentProtocol = self.dependenciesResolver.resolve(forOptionalType: UserSegmentProtocol.self) {
            userSegmentDelegate.getUserSegment { [weak self] result, _ in
                guard let self = self else { return }
                self.view?.setSantanderLogo(result.segmentImage())
            }
        } else {
            view?.setSantanderLogo(info.segmentType.segmentImage())
        }
    }
    
    private func refreshSection(_ sec: Int) {
        sectionsToUpdate.insert(sec)
        refreshInfo()
        controller?.reload(sectionsToUpdate)
        sectionsToUpdate.removeAll()
    }
    
    private func refreshRows(_ sec: Int, _ row: Int) {
        guard controller?.isValidIndex(sec, row) ?? false else { return }
        rowsToUpdate.append(IndexPath(row: row, section: sec))
        controller?.reloadRows(rowsToUpdate)
        rowsToUpdate.removeAll()
    }
    
    private func getMovementsOfAccounts(_ accounts: [AccountEntity]?) {
        accounts?.forEach {
            getMovementsOfAccount($0)
        }
    }
    
    private func getMovementsOfAccount(_ account: AccountEntity) {
        dataManager?.getUnreadMovementsOfAccount(account, { [weak self] response in
            if let pos = self?.classicWrapper?.setNotification(response.newMovements, in: account) {
                guard pos.0 != nil else { return }
                self?.refreshInfo()
                guard let sec = self?.classicWrapper?.accountsSection() else { return }
                guard let row = pos.1 else { self?.refreshSection(sec); return }
                self?.refreshRows(sec, row)
            }
        }, failure: { _ in })
    }
    
    private func getMovementsOfCards(_ cards: [CardEntity]?) {
        cards?.forEach {
            getMovementsOfCard($0)
        }
    }
    
    private func getMovementsOfCard(_ card: CardEntity) {
        dataManager?.getUnreadMovementsOfCard(card, { [weak self] response in
            if let pos = self?.classicWrapper?.setNotification(response.newMovements, in: card) {
                guard pos.0 != nil else { return }
                self?.refreshInfo()
                guard let sec = self?.classicWrapper?.cardsSection() else { return }
                guard let row = pos.1 else { self?.refreshSection(sec); return }
                self?.refreshRows(sec, row)
            }
        }, failure: { _ in })
    }
    
    private func selectBox(type: ProductTypeEntity, isOpen: Bool) {
        dataManager?.getUserPreferencesValues(userId: classicWrapper?.configuration?.userId, { [weak self] response in
            guard let strongSelf = self else { return }
            let userPref = response.userPref
            if let foldingAction = strongSelf.trackerPage.foldingActionTrack(type: type, isOpen: isOpen) {
                strongSelf.trackEvent(foldingAction, parameters: [.pgType: GlobalPositionConstants.classicPgType])
            }
            let setBoxOpenAction: [ProductTypeEntity: (Bool) -> Void] = [
                .account: userPref.setAccountBoxOpen,
                .card: userPref.setCardBoxOpen,
                .managedPortfolio: userPref.setPortfolioManagedBoxOpen,
                .notManagedPortfolio: userPref.setPortfolioNotManagedBoxOpen,
                .deposit: userPref.setDepositBoxOpen,
                .loan: userPref.setLoanBoxOpen,
                .stockAccount: userPref.setStockBoxOpen,
                .pension: userPref.setPensionsBoxOpen,
                .fund: userPref.setFundsBoxOpen,
                .insuranceSaving: userPref.setInsuranceSavingBoxOpen,
                .insuranceProtection: userPref.setInsuranceProtectionBoxOpen
            ]
            setBoxOpenAction[type]?(isOpen)
            strongSelf.dataManager?.updateUserPreferencesValues(userPrefEntity: userPref)
        }, failure: { _ in })
    }
    
    private func updateDiscreteModeState() {
        dataManager?.getUserPreferencesValues(userId: classicWrapper?.configuration?.userId, { [weak self] response in
            var userPref = response.userPref
            self?.toggleDiscreteMode(userPref: &userPref)
            let discreteModeActivated = self?.discreteModeActivated ?? userPref.isDiscretModeActivated()
            self?.toggleDiscreteModeAppearance(discreteModeActivated)
            self?.showDiscreteModeAlert(isEnabled: discreteModeActivated)
            self?.dataManager?.updateUserPreferencesValues(userPrefEntity: userPref)
            if let availableActions = self?.availableActions {
                self?.view?.setAvailableActions(Array(availableActions.prefix(4)))
            }
            self?.view?.setVisibilityBalanceCarousel(userPref.isChartModeActivated())
            self?.setupExpenses(animated: false)
            self?.update()
            self?.doubleTapping = false
        }, failure: { [weak self] _ in
            self?.doubleTapping = false
        })
    }
    
    func toggleDiscreteMode(userPref: inout UserPrefEntity) {
        let isDiscreteModeEnabled = self.discreteModeActivated ?? userPref.isDiscretModeActivated()
        self.discreteModeActivated = !isDiscreteModeEnabled
        userPref.setDiscreteMode(discreteModeIsOn: !isDiscreteModeEnabled)
        self.view?.updateSantanderLogoAccessibility(discretMode: !isDiscreteModeEnabled)
    }
    
    func toggleDiscreteModeAppearance(_ discreteModeActivated: Bool) {
        self.controller?.discreteModeEnabled = discreteModeActivated
        self.currentBalanceItem.setDiscreteMode(discreteModeActivated)
        self.expensesItem.setDiscreteMode(discreteModeActivated)
        self.expensesItem.blurred = discreteModeActivated
    }
    
    private func showDiscreteModeAlert(isEnabled: Bool) {
        let enabledString = "pg_alert_discreteModeActivated"
        let disabledString = "pg_alert_discreteModeOff"
        let message: LocalizedStylableText = self.stringLoader.getString(isEnabled ? enabledString : disabledString)
        view?.showAlert(with: message, messageType: .info)
    }
    
    private func presentInsurancesMessage() {
        let accept = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept"), does: nil)
        self.view?.showOldDialog(title: nil, description: self.stringLoader.getString("insurancesDetail_label_error"), acceptAction: accept, cancelAction: nil, isCloseOptionAvailable: false)
    }
    
    private func saveDiscreteModeState() {
        guard let discreteModeEnabled = self.discreteModeActivated else { return }
        dataManager?.getUserPreferencesValues(userId: classicWrapper?.configuration?.userId, { [weak self] response in
            let userPref = response.userPref
            userPref.setDiscreteMode(discreteModeIsOn: discreteModeEnabled)
            self?.dataManager?.updateUserPreferencesValues(userPrefEntity: userPref)
        }, failure: { _ in
            
        })
    }
    
    func didSelectPregrantedBanner(_ offer: ExpirableOfferEntity?) {
        trackEvent(.pregrantedBanner, parameters: [.pgType: GlobalPositionConstants.classicPgType])
        guard let offer = offer else { return }
        didSelectPullOffer(offer)
    }
    
    func didSelectPullOffer(_ info: ExpirableOfferEntity) {
        delegate?.didSelectOffer(info)
        guard info.expiresOnClick, let offerId = info.id else { return }
        dataManager?.disableOffer(offerId, { [weak self] in
            self?.isPregrantedOfferExpired(offerId)
        })
    }
    
    func isPregrantedOfferExpired(_ offerId: String) {
        let empty = classicWrapper?.isPregrantedOfferExpired(offerId)
        (empty ?? true) ? update() : refreshInfo()
    }
}

extension PGClassicPresenter: ModuleLauncher {}

// MARK: - GlobalPositionReloadable

extension PGClassicPresenter: GlobalPositionReloadable {
    func reload() {
        self.notPGValuesOnAppear = true
        self.delegate?.globalPositionDidReload()
        dataManager?.getPGValues({ [weak self] response in
            guard let self = self else { return }
            self.enableInsuranceDetail = response.enableInsuranceDetail
            self.pullOfferCandidates = response.pullOfferCandidates
            self.setViewInfo(response)
            self.classicWrapper?.refreshUserPref(response)
            self.view?.setUserName(self.classicWrapper?.configuration?.userName ?? "", birthDay: self.isBirthday())
            self.setupCurrentBalance(balanceValue: response.totalFinance, financingValue: response.financingTotal, discreteMode: response.userPref?.isDiscretModeActivated() ?? false, insuranceEnabled: response.isInsuranceEnabled)
            self.expensesItem.blurred = response.userPref?.isDiscretModeActivated() ?? false
            self.loadMonthlyBalance(animated: true)
            self.getMovementsOfAccounts(response.visibleAccounts)
            self.getMovementsOfCards(response.cards)
        }, failure: { _ in })
    }
}

// MARK: - ShortcutsDelegate

extension PGClassicPresenter: ShortcutsDelegate {
    func didSaveChanges(viewModels: [GpOperativesViewModel]) {
        let frequentOperativesFinal: [PGFrequentOperativeOptionProtocol] = viewModels.map { $0.type }
        reloadAvailableActions(viewModels)
        let frequentOperativesFinalKeys: [String] = frequentOperativesFinal.map { $0.rawValue }
        dataManager?.getUserPreferencesValues(userId: classicWrapper?.configuration?.userId, { [weak self] response in
            guard let strongSelf = self else { return }
            let userPref = response.userPref
            userPref.setFrequentOperativesKeys(frequentOperativesFinalKeys)
            strongSelf.dataManager?.updateUserPreferencesValues(userPrefEntity: userPref)
        }, failure: { _ in })
    }
}

extension PGClassicPresenter: OtherOperativesHelper {
    var otherOperativesDelegate: OtherOperativesActionDelegate? { delegate }
    var wrapper: OtherOperativesEvaluator? { classicWrapper }
    
    func goToMoreOperateOptions() {
        pgCoordinator.goToMoreOperateOptions()
    }
}

extension PGClassicPresenter: AutomaticScreenActionTrackable {
    
    var trackerManager: TrackerManager {
        return resolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: GlobalPositionPage {
        let emmaTrackEventList: EmmaTrackEventListProtocol = self.resolver.resolve()
        let emmaToken = emmaTrackEventList.globalPositionEventID
        return GlobalPositionPage(emmaToken: emmaToken)
    }
    
    func getTrackParameters() -> [String: String]? {
        [TrackerDimension.pgType.key: GlobalPositionConstants.classicPgType]
    }
}

extension PGClassicPresenter: EditBudgetHelper {
    
    func didSelectBudget() {
        dataManager?.getUserPreferencesValues(userId: classicWrapper?.configuration?.userId, { [weak self] response in
            guard let strongSelf = self else { return }
            let userBudget = response.userPref.getBudget()
            let budget = strongSelf.getEditBudgetData(userBudget: userBudget,
                                                      threeMonthsExpenses: strongSelf.monthlyBalance,
                                                      resolver: strongSelf.dependenciesResolver)
            strongSelf.expensesItem.showEditBudgetView(editBudget: budget, delegate: self)
        }, failure: { _ in })
    }
}

extension PGClassicPresenter: BudgetBubbleViewProtocol {
    func didPressSaveButton(budget: Double) {
        dataManager?.getUserPreferencesValues(userId: classicWrapper?.configuration?.userId, { [weak self] response in
            guard let strongSelf = self else { return }
            let userPref = response.userPref
            userPref.setBudget(budget)
            strongSelf.dataManager?.updateUserPreferencesValues(userPrefEntity: userPref)
            if let monthInfo = self?.monthlyBalance {
                self?.displayMonthlyExpensesWithBudget(budget, expenses: monthInfo, animated: false, showPredictiveExpense: true)
            }
        }, failure: { _ in })
        self.trackerManager.trackEvent(screenId: GlobalPositionBudgetPage().page, eventId: GlobalPositionBudgetPage.Action.save.rawValue, extraParameters: [TrackerDimension.textSearch.key: String(budget)])
    }
    
    func didShowBudget() {
        self.trackerManager.trackScreen(screenId: GlobalPositionBudgetPage().page, extraParameters: [:])
    }
    
    func didChangedSlide() {
        self.trackerManager.trackEvent(screenId: GlobalPositionBudgetPage().page, eventId: GlobalPositionBudgetPage.Action.slide.rawValue, extraParameters: [:])
    }
}

private extension PGClassicPresenter {
    func displayMonthlyExpenses(_ expenses: [MonthlyBalanceRepresentable], animated: Bool, showPredictiveExpense: Bool) {
        dataManager?.getUserPreferencesValues(userId: classicWrapper?.configuration?.userId, { [weak self] response in
            guard let strongSelf = self else { return }
            let userPref = response.userPref
            strongSelf.displayMonthlyExpensesWithBudget(userPref.getBudget(), expenses: expenses, animated: animated, showPredictiveExpense: showPredictiveExpense)
            if let whatsNewEnabled = strongSelf.classicWrapper?.configuration?.isWhatsNewZoneEnabled {
                strongSelf.loadWhatsNewView(userPref: userPref, whatsNewEnabled: whatsNewEnabled)
            } else {
                strongSelf.dataManager?.getPGValues({ [weak self] response in
                    self?.loadWhatsNewView(userPref: userPref, whatsNewEnabled: response.isWhatsNewZoneEnabled)
                }, failure: { _ in })
            }
        }, failure: { _ in })
    }
    
    func displayMonthlyExpensesWithBudget(_ budget: Double?, expenses: [MonthlyBalanceRepresentable], animated: Bool, showPredictiveExpense: Bool) {
        var maximum = expenses.reduce(0) { (maximum, month) -> Decimal in
            return maximum < month.expense ? month.expense : maximum
        }
        
        let predictiveExpense = predictiveExpenses(expenses)
        if predictiveExpense > maximum { maximum = predictiveExpense}
        
        let predictiveExpenseSize: Float = maximum != 0 ? Float(truncating: (predictiveExpense as NSDecimalNumber).dividing(by: NSDecimalNumber(decimal: maximum))) : 0.0
        var budgetSize: Float = 0.0
        if maximum == 0 {
            budgetSize = 0.7
        } else if let userBudget = budget {
            let budgetDecimal = Decimal(userBudget)
            budgetSize = Float(truncating: (budgetDecimal as NSDecimalNumber).dividing(by: NSDecimalNumber(decimal: maximum)))
        } else {
            let budgetDecimal = Decimal(getEditBudgetData(userBudget: budget, threeMonthsExpenses: expenses, resolver: self.dependenciesResolver).budget)
            budgetSize = Float(truncating: (budgetDecimal as NSDecimalNumber).dividing(by: NSDecimalNumber(decimal: maximum)))
        }
        
        let expense: [ExpensesBarInfo] = expenses.map {
            let percentage: Float = maximum == 0 ? 0 : Float(truncating: ($0.expense as NSDecimalNumber).dividing(by: NSDecimalNumber(decimal: maximum)))
            let timeManager = resolver.resolve(for: TimeManager.self)
            let month = timeManager.toStringFromCurrentLocale(date: $0.date, outputFormat: .MMM) ?? ""
            let monthInfo = timeManager.toStringFromCurrentLocale(date: $0.date, outputFormat: .MMMM) ?? ""
            return ExpensesBarInfo(topTitle: AmountEntity(value: $0.expense).getStringValue(), barSize: percentage, bottomTitle: month.uppercased(), blurred: false, monthInfo: monthInfo)
        }
        expensesItem.setExpenses(expense, budgetSize: budgetSize, predictiveExpense: showPredictiveExpense ? predictiveExpense : nil, predictiveExpenseSize: showPredictiveExpense ? predictiveExpenseSize : nil, animated: animated, isBigWhatsNewBubble: self.isBigWhatsNewVisible)
    }
    
    func loadWhatsNewView(userPref: UserPrefEntity, whatsNewEnabled: Bool) {
        self.view?.isWhatsNewBigBubbleVisible(userPref.isWhatsNewBigBubbleVisible(),
                                              whatsNewEnabled: whatsNewEnabled,
                                              completion: {
                                                userPref.setWhatsNewBigBubbleVisible(true)
                                                self.dataManager?.updateUserPreferencesValues(userPrefEntity: userPref)
                                              })
    }
    
    func reloadAvailableActions(_ viewModels: [GpOperativesViewModel]) {
        view?.setAvailableActions(Array(viewModels.prefix(4)))
        getOtherOperatives(viewModels.map { $0.type })
    }
    
    func trackOperative(_ operative: PGFrequentOperativeOption) {
        guard operative != .contract || self.wrapper?.getOffer(forLocation: "OPERAR_PG") == nil else {
            return
        }
        guard
            let trackName = operative.trackName,
            let actionType = GlobalPositionPage.ActionType(rawValue: trackName)
        else { return }
        trackEvent(actionType, parameters: [.pgType: GlobalPositionConstants.classicPgType])
    }
    
    func isBirthday() -> Bool {
        return Calendar.current.isDateInToday(self.classicWrapper?.configuration?.userBirthday ?? Date(timeIntervalSince1970: 0.0))
    }
    
    func predictiveExpenses(_ expenses: [MonthlyBalanceRepresentable]) -> Decimal {
        guard Date().isAfterFifteenDaysInMonth(),
              let item = expenses.last else { return 0 }
        let todaysDay = Double(Date().dayInMonth())
        let monthDays = Double(Date().numberOfDaysInMonth())
        let expense = Double(truncating: NSDecimalNumber(decimal: item.expense))
        let predictiveExpense = Int(round((expense / todaysDay) * monthDays))
        return Decimal(predictiveExpense)
    }
    
    func analysisZone() {
        guard !checkingAnalysisZone else { return }
        checkingAnalysisZone = true
        Scenario(useCase: self.checkAnalysisZone)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] result in
                if result.visibleAnalysisZone {
                    self?.delegate?.didSelectAnalysisArea()
                }
            }
            .finally { [weak self] in
                self?.checkingAnalysisZone = false
            }
    }
    
    func didSelectFund(_ fund: FundEntity) {
        if self.dependenciesResolver.resolve(for: LocalAppConfig.self).isEnabledfundWebView {
            self.view?.showNotAvailableOperation()
        } else {
            self.coordinator.didSelectFund(fund: fund)
        }
    }
}

extension PGClassicPresenter: PGClassicTableViewControllerDelegate {
    func didSelectSection(_ type: ProductTypeEntity, idx: Int?) {
        classicWrapper?.switchHeader(type)
        guard
            let idx = idx,
            let collapsed = classicWrapper?.configuration?.collapsed[type]
        else { return update() }
        refreshInfo()
        collapsed ? controller?.expandSection(idx) : controller?.collapseSection(idx)
        self.selectBox(type: type, isOpen: collapsed)
        refreshSection(idx)
        self.view?.addWhatsNewBubbleToTableScroll()
    }
    
    func didSelectInfo(_ info: ElementEntity?) {
        guard let info = info else { return }
        if let account = info.elem as? AccountEntity {
            delegate?.didSelectAccount(account: account)
        } else if let card = info.elem as? CardEntity {
            delegate?.didSelectCard(card: card)
        } else if let fund = info.elem as? FundEntity {
            self.didSelectFund(fund)
        } else if let insurance = info.elem as? InsuranceSavingEntity {
            if self.enableInsuranceDetail {
                delegate?.didSelectInsuranceSaving(insurance: insurance)
            } else {
                self.presentInsurancesMessage()
            }
        } else if let insurance = info.elem as? InsuranceProtectionEntity {
            if self.enableInsuranceDetail {
                self.coordinator.didSelectInsuranceProtection(insurance: insurance)
            } else {
                self.presentInsurancesMessage()
            }
        } else if let loan = info.elem as? LoanEntity {
            delegate?.didSelectLoan(loan: loan)
        } else if let pension = info.elem as? PensionEntity {
            delegate?.didSelectPension(pension: pension)
        } else if let portfolio = info.elem as? PortfolioEntity {
            if portfolio.productId == "ManagedPortfolio" {
                self.getPortfolioWebViewConfig(portfolio: portfolio, isManaged: true)
            } else if portfolio.productId == "NotManagedPortfolio" {
                self.getPortfolioWebViewConfig(portfolio: portfolio, isManaged: false)
            }
        } else if let stockAccount = info.elem as? StockAccountEntity {
            delegate?.didSelectStockAccount(stockAccount: stockAccount)
        } else if let offer = info.elem as? PullOfferCompleteInfo {
            guard pullOffersDelegate != nil else {
                self.delegate?.didSelectOffer(offer.entity)
                return
            }
            pullOffersDelegate?.verifyOffer(entity: offer.entity, completion: { canContinue in
                if canContinue {
                    delegate?.didSelectOffer(offer.entity)
                }
            })
        } else if let movement = info.elem as? MovementCompleteInfo {
            delegate?.didSelectAccountMovement(movement: movement.movement, in: movement.account)
        } else if let deposit = info.elem as? DepositEntity {
            self.coordinator.didSelectDeposit(deposit: deposit)
        } else if let savingProduct = info.elem as? SavingProductEntity {
            delegate?.didSelectSavingProduct(savingProduct: savingProduct)
        }
    }
    
    func didSelectPullOffer(_ info: PullOfferCompleteInfo) {
        guard pullOffersDelegate != nil else {
            self.delegate?.didSelectOffer(info.entity)
            return
        }
        pullOffersDelegate?.verifyOffer(entity: info.entity, completion: { canContinue in
            if canContinue {
                self.delegate?.didSelectOffer(info.entity)
            }
        })
    }
    
    func didClosePullOffer(_ pullOffer: Any) {
        guard let pullOffer = pullOffer as? PullOfferCompleteInfo else { return }
        self.dataManager?.didExpireOffer(pullOffer.entity)
        classicWrapper?.removePullOffer(pullOffer)
        update()
    }
    
    func resizePullOffer(_ pullOffer: Any, to height: CGFloat) {
        guard let pullOffer = pullOffer as? PullOfferCompleteInfo else { return }
        classicWrapper?.resizePullOffer(pullOffer, to: height)
        update()
    }
    
    func activateCard(_ card: Any) {
        delegate?.didActivateCard(card)
    }
    
    func turnOnCard(_ card: Any) {
        delegate?.didTurnOnCard(card)
    }
    
    func moreOptionPress() {
        guard let view = view as? UIViewController else { return }
        
        let classicShortcutsViewController = resolver.resolve(for: ClassicShortcutsViewController.self)
        classicShortcutsViewController.setData(delegate: self, viewModels: availableActions)
        if #available(iOS 11.0, *) { view.navigationController?.delegate = view as? UINavigationControllerDelegate }
        view.navigationController?.pushViewController(classicShortcutsViewController, animated: true, completion: {
            view.navigationController?.view.setNeedsLayout()
            view.navigationController?.view.layoutIfNeeded()
        })
        
        trackEvent(.moreActions, parameters: [.pgType: GlobalPositionConstants.classicPgType])
    }
    
    func logoDidPress() {
        if !self.doubleTapping {
            self.doubleTapping = true
            self.updateDiscreteModeState()
        }
    }
    
    func didSelectAction(_ action: PGFrequentOperativeOptionProtocol, _ entity: Void) {
        if (view as? UIViewController)?.navigationController?.popToRootViewController(animated: true) != nil {
            frequentOperativeOptionSelected = action
            if let trackName = action.trackName {
                self.trackerManager.trackEvent(
                    screenId: ClassicShortcutPage().page,
                    eventId: ClassicShortcutPage.Action.action.rawValue,
                    extraParameters: [
                        TrackerDimension.pgType.key: GlobalPositionConstants.classicPgType,
                        TrackerDimension.directAccess.key: trackName
                    ]
                )
            }
        } else {
            switch action.getAction() {
            case .core(option: let option):
                self.trackOperative(option)
                self.navigateTo(operative: option)
            case .custom(action: let action):
                action()
            }
        }
    }
    
    func popToRootViewController(animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        (view as? UIViewController)?.navigationController?.popToRootViewController(animated: animated)
        CATransaction.setCompletionBlock(completion)
        CATransaction.commit()
    }
    
    func switchFilterHeader(_ idx: Int) {
        if let state = classicWrapper?.switchFilterHeader() {
            refreshInfo()
            state ? controller?.expandFilter(idx) : controller?.collapseFilter(idx)
        }
    }
    
    func filterDidSelect(_ filter: PGInterventionFilter) {
        if classicWrapper?.filterDidSelect(filter) ?? false {
            controller?.scrollToTop()
            dataManager?.setInterventionFilter(filter)
            update()
        }
    }
    
    func didPressAvios() {
        pgCoordinator.goToAviosDetail()
    }
    
    func didPressConfigureGP() {
        localAppConfig.isEnabledConfigureWhatYouSee ? delegate?.didSelectConfigureGPProducts() : view?.showNotAvailableOperation()
    }
    
    func didSelectTimeLineOffer() {
        guard let offer = self.classicWrapper?.getOffer(forLocation: GlobalPositionPullOffers.pgTimeline) else {
            return
        }
        self.delegate?.didSelectOffer(offer.entity)
    }
    
    func didSelectedSizeOffer(_ offer: OfferEntity) {
        self.delegate?.didSelectOffer(offer)
    }
    
    func didSelectTimeLine() {
        trackEvent(.timeline, parameters: [.pgType: GlobalPositionConstants.classicPgType])
        self.delegate?.didSelectTimeLine()
    }
    
    func didSelectWhatsNew() {
        trackEvent(.bubble, parameters: [.pgType: GlobalPositionConstants.classicPgType])
        pgCoordinator.goToWhatsNew()
    }
    
    func didSelectOffer(offer: OfferEntity) {
        self.delegate?.didSelectOffer(offer)
    }
    
    func didEndedPGBookmarkScroll() {
        trackEvent(.swipeCarousel, parameters: [.pgType: GlobalPositionConstants.classicPgType])
    }
    
    func didScroll() { }
    
    // MARK: Favourite Carousel Actions
    func newShippmentDidPress() {
        trackEvent(.newShippment, parameters: [.pgType: GlobalPositionConstants.classicPgType])
        delegate?.goToNewShipment()
    }
    
    func newFavContactDidPress() {
        trackEvent(.newFavContact, parameters: [.pgType: GlobalPositionConstants.classicPgType])
        delegate?.addFavourite()
    }
    
    func didTapInFavContact(_ viewModel: FavouriteContactViewModel) {
        self.trackerManager.trackEvent(screenId: FavouriteCarouselPage().page, eventId: FavouriteCarouselPage.Action.favouriteSelected.rawValue, extraParameters: [TrackerDimension.pgType.key: GlobalPositionConstants.classicPgType])
        guard let view = self.view else { return }
        delegate?.didSelectFavouriteContact(viewModel.contact, launcher: self, delegate: view)
    }
    
    func didTapInHistoricSendMoney() {
        trackEvent(.historicSendMoney, parameters: [.pgType: GlobalPositionConstants.classicPgType])
        delegate?.didTapInHistoricSendMoney()
    }
}

private extension PGClassicPresenter {
    // MARK: - Favourite Carousel methods
    func reloadFavouritesCarousel(_ dataList: [OnePayCollectionInfo]) {
        self.view?.setFavouriteCarousel(dataList)
        guard let items = controller?.cellsInfo else { return }
        guard let section = classicWrapper?.indexOfSection(in: items, withIdentifier: "OnePayTableViewCell") else { return }
        refreshSection(section)
    }
    
    func deleteFavouriteCarousel() {
        guard let items = controller?.cellsInfo else { return }
        guard let section = classicWrapper?.indexOfSection(in: items, withIdentifier: "OnePayTableViewCell") else { return }
        controller?.removeFavouriteCarousel(section)
        self.update()
    }
    
    func callFavouriteCarouselIfNeeded() {
        DispatchQueue.main.async {
            if self.isFavouriteCarouselEnabled == true {
                self.getIsFavouriteCarouselCached { [weak self] status in
                    if !status {
                        guard let self = self else { return }
                        let updatedPills = self.cacheDefaultPills.isEmpty
                            ? OnePayPGConfiguration.loadingPills
                            : self.cacheDefaultPills
                        self.reloadFavouritesCarousel(updatedPills)
                    }
                }
                self.loadFavouriteCarousel()
            }
        }
    }
    
    func getIsFavouriteCarouselCached(_ completion: @escaping((Bool) -> Void)) {
        self.dataManager?.getLocalFavouritesContacts({
            completion(true)
        }, failure: { _ in
            completion(false)
        })
    }
    
    func loadFavouriteCarousel() {
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        self.dataManager?.getFavouritesContacts({ [weak self] response in
            guard let self = self else { return }
            let onePayPGViewModel = OnePayPGViewModel(response.contactEntityList, baseUrl: self.baseURLProvider.baseURL, colorsEngine: colorsEngine)
            let onePayPGInfoList = onePayPGViewModel.loadDataInFavouriteCarousel(response.contactEntityList)
            if onePayPGInfoList.count == OnePayPGConfiguration.defaultPills.count {
                self.cacheDefaultPills = onePayPGInfoList
            }
            DispatchQueue.main.async {
                self.reloadFavouritesCarousel(onePayPGInfoList)
            }
        }, failure: { _ in
            let defaultPills = OnePayPGConfiguration.defaultPills
            self.reloadFavouritesCarousel(defaultPills)
        })
    }
    
    func configureFavouriteCarousel(_ info: GetPGUseCaseOkOutput) {
        guard info.isClassicOnePayCarouselEnabled else {
            self.deleteFavouriteCarousel()
            self.isFavouriteCarouselEnabled = false
            return
        }
        self.isFavouriteCarouselEnabled = true
        let defaultPills = OnePayPGConfiguration.defaultPills
        self.reloadFavouritesCarousel(defaultPills)
    }
    
    func checkFrequentOperativeOptionSelected() {
        guard let frequentOperativeOptionSelected = frequentOperativeOptionSelected else {
            return
        }
        switch frequentOperativeOptionSelected.getAction() {
        case .core(let option):
            if let otherOperativesDelegate = self.dependenciesResolver.resolve(forOptionalType: OtherOperativesModifierProtocol.self),
               !otherOperativesDelegate.isOtherOperativeEnabled(option) {
                Toast.show(localized("generic_alert_notAvailableOperation"))
            } else {
                self.navigateTo(operative: option)
            }
        case .custom(let action):
            if let location = frequentOperativeOptionSelected.getLocation(),
               let offer = wrapper?.getOffer(forLocation: location) {
                self.delegate?.didSelectOffer(offer.entity)
            } else {
                action()
            }
        }
        self.frequentOperativeOptionSelected = nil
    }
}

private extension PGClassicPresenter {
    
    func getPortfolioWebViewConfig(portfolio: PortfolioEntity, isManaged: Bool) {
        let input = GetPortfolioWebViewConfigurationUseCaseInput(portfolio: portfolio, isManaged: isManaged)
            Scenario(useCase: self.portfolioWebViewConfigUseCase, input: input)
                .execute(on: self.dependenciesResolver.resolve())
                .onSuccess { [weak self] response in
                    self?.delegate?.goToWebView(configuration: response.configuration)
                }
                .onError { _ in
                    if isManaged {
                        self.delegate?.didSelectManagedPortfolio(portfolio: portfolio)
                    } else {
                        self.delegate?.didSelectNotManagedPortfolio(portfolio: portfolio)
                    }
                }
        }
    
    func setupExpensesItemActions() {
        expensesItem.action = { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .limit:
                self.trackEvent(.editExpenses, parameters: [.pgType: GlobalPositionConstants.classicPgType])
                self.didSelectBudget()
            case .graph:
                self.analysisZone()
            default:
                break
            }
        }
    }
    
    func setMonthlyBalanceToZero() {
        let expensesAndIncomes: [MonthlyBalanceRepresentable] = [
            DefaultMonthlyBalance(date: Date().getDateByAdding(months: -2, ignoreHours: true), expense: 0.0, income: 0.0),
            DefaultMonthlyBalance(date: Date().getDateByAdding(months: -1, ignoreHours: true), expense: 0.0, income: 0.0),
            DefaultMonthlyBalance(date: Date(), expense: 0.0, income: 0.0)]
        self.monthlyBalance = expensesAndIncomes
        self.displayMonthlyExpenses(expensesAndIncomes, animated: false, showPredictiveExpense: false)
    }
}

private extension PGClassicPresenter {
    
    func loadMonthlyBalance(animated: Bool) {
        dataManager?.getMonthlyBalance { [weak self] months in
            if months.count > 0 {
                self?.monthlyBalance = months
                self?.displayMonthlyExpenses(months, animated: animated, showPredictiveExpense: true)
            } else {
                self?.setMonthlyBalanceToZero()
            }
            self?.postLoadMonthlyBalance()
        }
    }
    
    func postLoadMonthlyBalance() {
        self.view?.showPendingSolicitudesIfNeeded()
        guard self.controller?.cellsInfo != nil else { return }
        self.dataManager?.getLoanBannerLimits { [weak self] bannerEntity in
            guard let self = self else { return }
            if let loanBanner = bannerEntity {
                self.classicWrapper?.setLoanBannerLimits(limits: loanBanner)
                self.callFavouriteCarouselIfNeeded()
                self.update()
            }
        }
        self.dataManager?.getLoanSimulatorLimits { [weak self] simulationEntity in
            guard let self = self else { return }
            if let loanLimits = simulationEntity {
                self.classicWrapper?.setLoanSimulatorLimits(limits: loanLimits)
            } else {
                self.classicWrapper?.setLoanSimulatorLimits(limits: nil)
            }
            self.callFavouriteCarouselIfNeeded()
            self.update()
        }
    }
}
