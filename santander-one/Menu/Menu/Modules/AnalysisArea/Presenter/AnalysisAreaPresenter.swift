import Foundation
import CoreFoundationLib
import UI
import CoreDomain

public enum AccountMovementsType {
    case incomes
    case expenses
}

protocol AnalysisAreaPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: AnalysisAreaViewProtocol? { get set }
    var selectedMonthAsSegmentIndex: Int { get }
    func viewDidLoad()
    func didSelectMenu()
    func didSelectDismiss()
    func loadTimeLineStartingWith(_ date: Date)
    func didSelectedOffer(_ viewModel: OfferBannerViewModel?)
    func didChangedSegmentedWithMonth(_ currentMonth: Int)
    func didSelectBudget(originalView: UIView, newBudget: Bool)
    func didPressSaveButton(budget: Double)
    func didExpandFinancialHealthView()
    func didSelectTimelineCellType(_ expenseType: ExpenseType)
    func loadReportForMovementType(_ type: AccountMovementsType, pfmMonth: MonthlyBalanceRepresentable?)
}

class AnalysisAreaPresenter {
    weak var view: AnalysisAreaViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private let locations: [PullOfferLocation] = PullOffersLocationsFactoryEntity().oldAnalysisArea
    private var selectedMonthIndex: Int?
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity]?
    private var timeLineResultsCache: [Date: TimeLineViewModel] = [Date: TimeLineViewModel]()
    private var enabledSections: [AnalysisAreaSections] = [AnalysisAreaSections]()
    private var coordinatorDelegate: OldAnalysisAreaCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: OldAnalysisAreaCoordinatorDelegate.self)
    }
    
    var coordinator: OldAnalysisAreaCoordinator {
        return self.dependenciesResolver.resolve(for: OldAnalysisAreaCoordinator.self)
    }
    
    private var pfmController: PfmControllerProtocol? {
        return dependenciesResolver.resolve(for: PfmControllerProtocol.self)
    }
    
    private var dependenciesEngine: DependenciesDefault {
        return DependenciesDefault(father: dependenciesResolver)
    }
    
    private var timeLineUseCase: TimeLineMovementsUseCase {
        return dependenciesResolver.resolve(for: TimeLineMovementsUseCase.self)
    }
    
    private var getPullOffersCandidatesUseCase: GetOffersCandidatesUseCase {
        self.dependenciesResolver.resolve()
    }
    
    private var getAnalysisSectionsUseCase: GetAnalysisSectionsUseCase {
        self.dependenciesResolver.resolve(for: GetAnalysisSectionsUseCase.self)
    }
    
    private var getFinancialHealthUseCase: GetFinancialHealthUseCase {
        self.dependenciesResolver.resolve()
    }
    
    private var getAllTricksUseCase: GetAllTricksUseCase {
        self.dependenciesResolver.resolve(for: GetAllTricksUseCase.self)
    }
    
    private var getExpensesIncomeCategoriesUseCase: ExpensesIncomeCategoriesUseCase {
        self.dependenciesResolver.resolve(for: ExpensesIncomeCategoriesUseCase.self)
    }
    
    private var localAppConfig: LocalAppConfig {
        dependenciesEngine.resolve(for: LocalAppConfig.self)
    }
    
    private var getAnalysisFinancialCushionUseCase: GetAnalysisFinancialCushionUseCase {
        self.dependenciesResolver.resolve()
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    deinit {
        self.pfmController?.removePFMSubscriber(self)
    }
    
    var userPreferences: GetUserPrefWithoutUserIdUseCase {
        self.dependenciesResolver.resolve(for: GetUserPrefWithoutUserIdUseCase.self)
    }
    
    var updateUserPreferences: UpdateUserPreferencesUseCase {
        self.dependenciesResolver.resolve(for: UpdateUserPreferencesUseCase.self)
    }
    
    var piggyBankPreferences: GetPiggyBankUseCase {
        self.dependenciesResolver.resolve(for: GetPiggyBankUseCase.self)
    }
    
    var financialCushionHelp: GetAnalysisFinancialCushionUseCase {
        self.dependenciesResolver.resolve(for: GetAnalysisFinancialCushionUseCase.self)
    }
    
    var financialBudgetHelp: GetAnalysisFinancialBudgetHelpUseCase {
         self.dependenciesResolver.resolve(for: GetAnalysisFinancialBudgetHelpUseCase.self)
     }
    
    private var baseUrlProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    var baseUrl: String? {
        self.baseUrlProvider.baseURL
    }
    
    private var analysisCarouselViewModel: AnalysisCarouselViewModel?
    private var userBudget: Double?
    private var months: [MonthlyBalanceRepresentable]?
    private var savingTips: [SavingTipViewModel]?
    
    private var selectedDate: Date?
}

// MARK: - Private methods

private extension AnalysisAreaPresenter {
    func loadOffers() {
        UseCaseWrapper(
            with: getPullOffersCandidatesUseCase.setRequestValues(requestValues: GetOffersCandidatesUseCaseInput(locations: self.locations)),
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                self?.pullOfferCandidates = result.pullOfferCandidates
                self?.showLocation()
            }
        )
    }
    
    func showLocation() {
        guard let offersCandidates = self.pullOfferCandidates else {
            return
        }
        for (location, offerEntity) in offersCandidates {
            if self.locations.first(where: {$0.stringTag == location.stringTag}) != nil {
                let viewModel = OfferBannerViewModel(entity: offerEntity)
                if let analysisType = AnalysisAreaLocations(rawValue: location.stringTag) {
                    self.view?.loadOfferBanners(analysisType, viewModel: viewModel)
                }
            }
        }
    }
    
    func loadFinancialCushionHelp(_ cushion: Int) {
        let input = GetAnalysisFinancialCushionUseCaseInput(cushion: cushion)
        Scenario(useCase: financialCushionHelp, input: input)
            .execute(on: self.dependenciesResolver.resolve(for: UseCaseHandler.self))
            .onSuccess { [weak self] pullOferRange in
                guard let strongSelf = self,
                      let offer = pullOferRange.financialCushionOffer else {
                    self?.view?.hideCushionTipsView()
                    return
                }
                let offerViewModel = OfferCustomTipViewModel(entity: offer.offer, title: offer.title, icon: offer.icon, baseUrl: strongSelf.baseUrl)
                strongSelf.view?.showCushionTipsView(offerViewModel, action: {
                    guard let offer = offerViewModel.offerEntity else { return }
                    strongSelf.didSelectedOffer(OfferBannerViewModel(entity: offer))
                    strongSelf.trackEvent(.financialCushion)
                })
            }
            .onError { [weak self] _ in
                guard let self = self else { return }
                self.view?.hideCushionTipsView()
            }
    }
    
    func loadFinancialBudgetHelp(_ cushion: Int) {
        let input = GetAnalysisFinancialBudgetHelpUseCaseInput(financialBudgetMonths: cushion, currentDayNumber: Date().dayInMonth())
        Scenario(useCase: financialBudgetHelp, input: input)
            .execute(on: self.dependenciesResolver.resolve(for: UseCaseHandler.self))
            .onSuccess { [weak self] pullOfferBudget in
                guard let strongSelf = self,
                      let offer = pullOfferBudget.financialBudgetOffer else {
                    self?.view?.hideBudgetTipsView()
                    return
                }
                let offerViewModel = OfferCustomTipViewModel(entity: offer.offer, title: offer.title, icon: offer.icon, baseUrl: strongSelf.baseUrl)
                strongSelf.view?.showBudgetTipsView(offerViewModel, action: {
                    guard let offer = offerViewModel.offerEntity else { return }
                    strongSelf.didSelectedOffer(OfferBannerViewModel(entity: offer))
                    strongSelf.trackEvent(.clickHelpBudget)
                })
            }
            .onError { [weak self] _ in
                guard let self = self else { return }
                self.view?.hideBudgetTipsView()
            }
    }
}

extension AnalysisAreaPresenter: AnalysisAreaPresenterProtocol {
    var selectedMonthAsSegmentIndex: Int {
        self.selectedMonthIndex ?? -1
    }
    
    func didSelectedOffer(_ viewModel: OfferBannerViewModel?) {
        self.coordinatorDelegate.didSelectOffer(viewModel?.offer)
    }
    
    func loadTimeLineStartingWith(_ date: Date) {
        guard let beginingOfSelectedMonth = date.startOfMonthLocalTime(), enabledSections.contains(.movements) else {
            self.view?.hideTimeLineLoading()
            return
        }
        
        self.selectedDate = beginingOfSelectedMonth
        
        if let cachedViewModel = self.timeLineResultsCache[beginingOfSelectedMonth] {
            let month = date.monthOfYear()
            var viewModel = cachedViewModel
            viewModel.setCurrentMonth(month)
            self.view?.timeLineDataReady(viewModel: viewModel)
            return
        }
        
        let input = TimeLineMovementsInputUseCase(date: beginingOfSelectedMonth,
                                                  offset: "",
                                                  limit: 100,
                                                  direction: .forward)
        UseCaseWrapper(with: self.timeLineUseCase.setRequestValues(requestValues: input), useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self), onSuccess: { (success) in
            var viewModel = TimeLineViewModel(timeLineResponse: success.timeLineResult)
            self.timeLineResultsCache.updateValue(viewModel, forKey: beginingOfSelectedMonth)
            let month = date.monthOfYear()
            viewModel.setCurrentMonth(month)
            self.view?.timeLineDataReady(viewModel: viewModel)
        }, onError: { _ in
            self.view?.hideTimeLineLoading()
        })
    }
    
    func viewDidLoad() {
        getEnabledSections()
        self.loadOffers()
        let months = self.pfmController?.monthsHistory
        if months == nil {
            self.view?.showLoading()
            if localAppConfig.isEnabledPfm {
                self.pfmController?.registerPFMSubscriber(with: self)
            } else {
                getMonthlyBalance()
            }
        } else if let optionalMonths = months {
            self.view?.headerDataReady(viewModel: HeaderViewModel(months: optionalMonths))
            self.setAnalysisCarouselViewModel(optionalMonths: optionalMonths )
            self.setFinancialHealth(optionalMonths)
        }
        self.checkPiggyBank()
        setSavingTips()
        trackScreen()
    }
    
    func didSelectMenu() {
        coordinator.showMenu()
    }
    
    func didSelectDismiss() {
        self.coordinator.dismiss()
    }
    
    func didChangedSegmentedWithMonth(_ currentMonth: Int) {
        selectedMonthIndex = currentMonth
        analysisCarouselViewModel?.didSelectedCurrentMonth(currentMonth)
        setCarouselData()
    }
    
    func didPressSaveButton(budget: Double) {
        MainThreadUseCaseWrapper(
            with: userPreferences,
            onSuccess: { [weak self] response in
                guard let strongSelf = self else { return }
                let userPref = response.userPref
                userPref.setBudget(budget)
                
                strongSelf.updateUserPref(userPref: userPref, budget: budget)
            }
        )
        trackerManager.trackEvent(screenId: OldAnalysisAreaBudgetPage().page, eventId: OldAnalysisAreaBudgetPage.Action.save.rawValue, extraParameters: [:])
    }
    
    func didExpandFinancialHealthView() {
        trackEvent(.expand, parameters: [:])
    }
    
    func updateUserPref(userPref: UserPrefEntity, budget: Double) {
        MainThreadUseCaseWrapper(
            with: self.updateUserPreferences.setRequestValues(requestValues: UpdateUserPreferencesUseCaseInput(userPref: userPref)),
            onSuccess: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.reloadWithBudget(budget: budget)
            }
        )
    }
    
    func reloadWithBudget(budget: Double) {
        self.userBudget = budget
        self.updateModelWithBudget()
    }
    
    func didSelectTimelineCellType(_ expenseType: ExpenseType) {
        switch expenseType {
        case .transferEmitted, .transferReceived, .bizumEmitted, .bizumReceived:
            didSelectTransfer(expenseType)
        case .reducedDebt:
            didSelectDebts()
        case .subscription:
            didSelectSubscriptions()
        case .receipt:
            didSelectReceipt(expenseType)
        }
    }
    
    func loadReportForMovementType(_ type: AccountMovementsType, pfmMonth: MonthlyBalanceRepresentable?) {
        guard let monthEntity = pfmMonth else {
            return
        }
        self.coordinator.goToMovementsReportsFor(type: type, pfmMonth: monthEntity)
    }
    
    func trackEvent(_ event: OldAnalysisAreaPage.Action) {
        trackEvent(event, parameters: [:])
    }
}

extension AnalysisAreaPresenter: PfmControllerSubscriber {
    func finishedPFMAccount(account: AccountEntity) {}
    
    func finishedPFMCard(card: CardEntity) {}
    
    func finishedPFM(months: [MonthlyBalanceRepresentable]) {
        self.view?.dismissLoading()
        self.view?.headerDataReady(viewModel: HeaderViewModel(months: months))
        self.setAnalysisCarouselViewModel(optionalMonths: months)
        self.setFinancialHealth(months)
        self.checkPiggyBank()
    }
}

private extension AnalysisAreaPresenter {
    func getMonthlyBalance() {
        guard let useCase = self.dependenciesResolver.resolve(firstOptionalTypeOf: GetMonthlyBalanceUseCase.self) else { return }
        Scenario(useCase: useCase)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] response in
                self?.pfmController?.monthsHistory = response.data
                self?.setMonthsHistory(response.data)
                self?.view?.dismissLoading()
            }
            .onError { [weak self] _ in
                self?.setEmptyViewConfiguration()
                self?.view?.dismissLoading()
            }
    }
    
    func setEmptyViewConfiguration() {
        self.pfmController?.monthsHistory = nil
        self.setMonthsHistory([DefaultMonthlyBalance(date: Date().addMonth(months: -2), expense: 0.0, income: 0.0),
                               DefaultMonthlyBalance(date: Date().addMonth(months: -1), expense: 0.0, income: 0.0),
                               DefaultMonthlyBalance(date: Date(), expense: 0.0, income: 0.0)])
    }
    
    func setMonthsHistory(_ months: [MonthlyBalanceRepresentable]) {
        self.view?.headerDataReady(viewModel: HeaderViewModel(months: months))
        self.setAnalysisCarouselViewModel(optionalMonths: months )
        self.setFinancialHealth(months)
    }
    
    func setSavingTips() {
        UseCaseWrapper(with: self.getAllTricksUseCase, useCaseHandler: dependenciesResolver.resolve(), onSuccess: { [weak self] (result) in
            guard let strongSelf = self, !result.tricks.isEmpty else {
                self?.view?.hideSavingTipsView()
                return
            }
            let tipsModels: [SavingTipViewModel] = result.tricks.map({ trick in
                SavingTipViewModel(entity: trick, dependenciesResolver: strongSelf.dependenciesResolver)
            })
            strongSelf.savingTips = tipsModels
            strongSelf.view?.setSavingTips(tipsModels)
            }, onError: { [weak self] _ in
                self?.view?.hideSavingTipsView()
        })
    }
    
    func setCarouselData() {
        guard let analysisCarouselViewModel = analysisCarouselViewModel else { return }
        if userBudget != nil,
           let budgetAvailablePercentajeValue = analysisCarouselViewModel.budgetPercentageValue {
            let availableBudgetPercentaje: Double = Double(truncating: NSDecimalNumber(decimal: budgetAvailablePercentajeValue))
            loadFinancialBudgetHelp(100 + Int(availableBudgetPercentaje))
        } else {
            view?.hideBudgetTipsView()
        }
        view?.carouselDataReady(viewModel: analysisCarouselViewModel)
    }
    
    func setAnalysisCarouselViewModel(optionalMonths: [MonthlyBalanceRepresentable]) {
        self.months = optionalMonths
        
        MainThreadUseCaseWrapper(
            with: userPreferences,
            onSuccess: { [weak self] response in
                self?.userBudget = response.userPref.getBudget()
                self?.analysisCarouselViewModel = AnalysisCarouselViewModel(months: optionalMonths, userBudget: self?.userBudget)
                self?.setCarouselData()
            }
        )
    }
    
    func updateModelWithBudget() {
        guard let userBudget = self.userBudget else { return }
        self.analysisCarouselViewModel?.updateUserBudget(userBudget)
        self.setCarouselData()
    }
    
    func setFinancialHealth(_ months: [MonthlyBalanceRepresentable]) {
        guard enabledSections.contains(.financialHealth) else {
            view?.setFinancialHealthViewHidden(true)
            return
        }
        
        MainThreadUseCaseWrapper(
            with: getFinancialHealthUseCase,
            onSuccess: { [weak self] response in
                guard let strongSelf = self else { return }
                let financialHealthViewModel = FinancialHealthViewModel(months: months,
                                                                        totalAccount: response.financialCushionAmount ?? Decimal.zero,
                                                                        totalInvestments: response.investmentsAmount ?? Decimal.zero)
                strongSelf.view?.setFinancialHealth(financialHealthViewModel)
                let cushionTime = Int(financialHealthViewModel.timeFinancialCushion)
                strongSelf.loadFinancialCushionHelp(cushionTime)
            }
        )
    }
    
    func getEnabledSections() {
        MainThreadUseCaseWrapper(with: self.getAnalysisSectionsUseCase,
                                 onSuccess: { [weak self] result in
                                    self?.enabledSections = result.enabledSections
                                    self?.setCountryConfiguration()
                                 })
    }
    
    func didSelectTransfer(_ expenseType: ExpenseType) {
        guard let selectedDate = selectedDate, let timeLineData = timeLineResultsCache[selectedDate]?.getOneMonthTimeLineData(selectedDate)  else {
            return
        }
        coordinator.goToMonthTransfers(selectedTransfer: expenseType, allTransfers: timeLineData)
    }
    
    func didSelectDebts() {
        guard let selectedDate = selectedDate, let timeLineData = timeLineResultsCache[selectedDate]?.getOneMonthTimeLineData(selectedDate) else {
            return
        }
        coordinator.goToMonthDebts(allDebts: timeLineData)
    }
    
    func didSelectSubscriptions() {
        guard let selectedDate = selectedDate, let timeLineData = timeLineResultsCache[selectedDate]?.getOneMonthTimeLineData(selectedDate) else {
            return
        }
        coordinator.goToMonthSubscriptions(allSubscriptions: timeLineData)
    }
    
    func didSelectReceipt(_ expenseType: ExpenseType) {
        guard let selectedDate = selectedDate, let timeLineData = timeLineResultsCache[selectedDate]?.getOneMonthTimeLineData(selectedDate)  else {
            return
        }
        coordinator.goToMonthReceipts(selectedReceipt: expenseType, allReceipts: timeLineData)
    }
    
    func setCountryConfiguration() {
        if !localAppConfig.analysisAreaHasTimelineSection,
           let idx = self.enabledSections.firstIndex(of: AnalysisAreaSections.movements) {
            self.enabledSections.remove(at: idx)
        }
        self.view?.incomesIsEnabled(localAppConfig.analysisAreaIsIncomeSelectable)
        self.view?.expensesIsEnabled(localAppConfig.analysisAreaIsExpensesSelectable)
    }
}

extension AnalysisAreaPresenter: SavingTipCollectionViewControllerDelegate {
    func didPressCell(index: Int) {
        guard let savingTips = self.savingTips else { return }
        view?.showSavingTipsCurtainView(savingTips: savingTips, index: index)
    }
}

extension AnalysisAreaPresenter: SavingTipCollectionViewDelegate {
    func scrollViewDidEndDecelerating() {
        trackEvent(.swipe, parameters: [:])
    }
}

extension AnalysisAreaPresenter: EditBudgetHelper {
    
    func didSelectBudget(originalView: UIView, newBudget: Bool) {
        let editBudget = getEditBudgetData(userBudget: self.userBudget,
                                           threeMonthsExpenses: self.months,
                                           resolver: self.dependenciesResolver)
        view?.showEditBudgetView(editBudget: editBudget, originView: originalView)
        if newBudget {
            trackerManager.trackScreen(screenId: OldAnalysisAreaBudgetPage().page, extraParameters: [:])
            trackEvent(.create, parameters: [:])
        } else {
            trackEvent(.edit, parameters: [:])
        }
    }
}

extension AnalysisAreaPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: OldAnalysisAreaPage {
        return OldAnalysisAreaPage()
    }
}

private extension AnalysisAreaPresenter {
    func checkPiggyBank() {
        UseCaseWrapper(with: piggyBankPreferences, useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self), onSuccess: { (success) in
            self.view?.showPiggyBankView(success.account)
        })
    }
}
