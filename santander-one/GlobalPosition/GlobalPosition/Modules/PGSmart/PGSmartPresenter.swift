//
//  PGSmartPresenter.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 19/12/2019.
//

import CoreFoundationLib
import CoreDomain

protocol PGSmartPresenterProtocol: OperativeSelectorLauncher, MenuTextWrapperProtocol, TopOfferCarouselViewDelegate {
    var view: PGSmartViewProtocol? { get set }
    var dataManager: PGDataManagerProtocol? { get set }
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    func viewDidDisappear()
    func mailPressed()
    func searchPressed()
    func drawerPressed()
    func newShippmentPressed()
    func newFavContactPressed()
    func didTapInFavContact(_ viewModel: FavouriteContactViewModel)
    func didTapInHistoricSendMoney()
    func usernamePressed()
    func didTapOnProduct(product: PGCellInfo)
    func activateCard(_ card: Any)
    func turnOnCard(_ card: Any)
    func didTapOnEditBudget(originView: UIView)
    func getUserName() -> String
    func isBirthday() -> Bool
    func interventionFilterDidSelect(_ filter: PGInterventionFilter)
    func didPressConfigureGP()
    func needDiscreteMode() -> Bool
    func logoPressed()
    func didSelectTimeLine()
    func didSelectTimeLineOffer()
    func didSelectedSizeOffer(_ offer: OfferEntity)
    func didEndedPGBookmarkScroll()
    func didTapOnAnalysis()
    func didSelect(experience: ExperiencesViewModel)
    func reload()
    func didClosePullOffer(_ pullOffer: Any)
    func didSelectWhatsNew()
    func didSelectAvios()
}

final class PGSmartPresenter {
    private let resolver: DependenciesResolver
    var dependenciesResolver: DependenciesResolver {
        return self.resolver
    }
    private var smartWrapper: SmartGlobalPositionWrapperProtocol?
    private var isTimelineEnabled: Bool?
    private var isPregrantedSimulatorEnabled: Bool?
    internal weak var view: PGSmartViewProtocol?
    internal weak var dataManager: PGDataManagerProtocol?
    private var loanViewModel: LoanSimulatorViewModel?

    var availableActions: [GpOperativesViewModel] = []

    private var stringLoader: StringLoader {
        return resolver.resolve(for: StringLoader.self)
    }
    
    var delegate: GlobalPositionModuleCoordinatorDelegate? {
        return resolver.resolve(for: GlobalPositionModuleCoordinatorDelegate.self)
    }
    
    private var pgCoordinator: PGClassicCoordinator {
        return resolver.resolve(for: PGClassicCoordinator.self)
    }
    
    private var pgSmartCoordinator: PGSmartCoordinator {
        return resolver.resolve(for: PGSmartCoordinator.self)
    }
    
    private var checkAnalysisZone: GetCheckAnalysisUseCase {
        return self.resolver.resolve(for: GetCheckAnalysisUseCase.self)
    }
    
    private var checkingAnalysisZone: Bool = false
    
    private var getSantanderExperiencesUseCase: GetSSantanderExperiencesUseCase {
        return self.resolver.resolve(for: GetSSantanderExperiencesUseCase.self)
    }
    
    private var baseURLProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    private var localAppConfig: LocalAppConfig {
        self.resolver.resolve(for: LocalAppConfig.self)
    }
    
    private var coordinator: GlobalPositionModuleCoordinatorProtocol {
        return self.resolver.resolve(for: GlobalPositionModuleCoordinatorProtocol.self)
    }
    
    private var frequentOperativeOptionSelected: PGFrequentOperativeOptionProtocol?
    private var bookmarkPullOffers: [(PullOfferBookmarkEntity, [OfferEntity])] = []
    private var doubleTapping: Bool = false
    private var discreteModeActivated: Bool?
    private var isFavouriteCarouselEnabled: Bool = false
    private var cacheDefaultPills: [OnePayCollectionInfo] = []
    private var enableInsuranceDetail: Bool = false
    private var monthlyBalance: [MonthlyBalanceRepresentable]?
    
    private var portfolioWebViewConfigUseCase: GetPortfolioWebViewConfigurationUseCase {
        return self.resolver.resolve(for: GetPortfolioWebViewConfigurationUseCase.self)
    }
    
    init(resolver: DependenciesResolver) {
        self.resolver = resolver
        let globalPositionReloadEngine = self.resolver.resolve(for: GlobalPositionReloadEngine.self)
        globalPositionReloadEngine.removeList()
        globalPositionReloadEngine.add(self)
        smartWrapper = self.resolver.resolve(for: SmartGlobalPositionWrapperProtocol.self)
    }
    
    func popToRootViewController(animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        (view as? UIViewController)?.navigationController?.popToRootViewController(animated: animated)
        CATransaction.setCompletionBlock(completion)
        CATransaction.commit()
    }
    
    func getUserName() -> String {
        guard let configuration = smartWrapper?.configuration else { return "" }
        return configuration.userName
    }
    
    func isBirthday() -> Bool {
        guard let configuration = smartWrapper?.configuration else { return false }
        return Calendar.current.isDateInToday(configuration.userBirthday ?? Date(timeIntervalSince1970: 0.0))
    }
}

extension PGSmartPresenter: ModuleLauncher {}

extension PGSmartPresenter: PGSmartPresenterProtocol {
    func viewDidLoad() {
        getIsSearchEnabled()
        delegate?.globalPositionDidLoad()
        getPGUserValues()
        dataManager?.getPGValues({ [weak self] response in
            guard let self = self else { return }
            self.enableInsuranceDetail = response.enableInsuranceDetail
            self.setViewInfo(response)
            self.setupCurrentBalance(balanceValue: response.totalFinance,
                                     financingValue: response.financingTotal,
                                     discreteMode: response.userPref?.isDiscretModeActivated() ?? false,
                                     insuranceEnabled: response.isInsuranceEnabled)
            self.getSantanderExperiences()
            self.loadTopOffer()
            self.configureFavouriteCarousel(response)
            self.loadMonthlyBalance()
            self.callFavouriteCarouselIfNeeded()
        }, failure: { _ in })
        self.setupExpenses()
        trackScreen()
    }
    
    private func getSantanderExperiences() {
        let baseUrlProvider = resolver.resolve(for: BaseURLProvider.self)
        UseCaseWrapper(
            with: getSantanderExperiencesUseCase,
            useCaseHandler: self.resolver.resolve(),
            onSuccess: { [weak self] result in
                let viewModels = result.santanderExperiences.map {
                    return ExperiencesViewModel($0, baseUrl: baseUrlProvider.baseURL)
                }
                self?.view?.setSantanderExperiences(viewModels)
        })
    }
    
    func viewDidAppear() {
        self.delegate?.globalPositionDidAppear()
        self.checkFrequentOperativeOptionSelected()
        self.view?.updatePendingSolicitudes()
    }

    func viewWillAppear() {
        dataManager?.getPGValues({ [weak self] response in
            self?.smartWrapper?.refreshUserPref(response)
            self?.view?.setUserName()
            self?.getMovementsOfAccounts(response.visibleAccounts)
            self?.getMovementsOfCards(response.cards)
            self?.loadTopOffer()
            self?.setupExpenses()
            self?.callFavouriteCarouselIfNeeded()
        }, failure: { _ in })
        getLoanBannerLimitsIfNeeded()
    }
    
    func viewDidDisappear() {
        self.saveDiscreteModeState()
        self.delegate?.globalPositionDidDisappear()
    }
    
    func mailPressed() { delegate?.didSelectMail() }
    func searchPressed() { delegate?.didSelectSearch() }
    func drawerPressed() { delegate?.didSelectMenu() }
    
    func newShippmentPressed() {
        trackEvent(.newShippment, parameters: [.pgType: GlobalPositionConstants.smartPgType])
        delegate?.goToNewShipment()
    }
    
    func newFavContactPressed() {
        trackEvent(.newFavContact, parameters: [.pgType: GlobalPositionConstants.smartPgType])
        delegate?.addFavourite()
    }
    
    func didTapInFavContact(_ viewModel: FavouriteContactViewModel) {
        self.trackerManager.trackEvent(screenId: FavouriteCarouselPage().page, eventId: FavouriteCarouselPage.Action.favouriteSelected.rawValue, extraParameters: [TrackerDimension.pgType.key: GlobalPositionConstants.smartPgType])
        guard let view = self.view else { return }
        delegate?.didSelectFavouriteContact(viewModel.contact, launcher: self, delegate: view)
    }
    
    func didTapInHistoricSendMoney() {
        trackEvent(.historicSendMoney, parameters: [.pgType: GlobalPositionConstants.smartPgType])
        delegate?.didTapInHistoricSendMoney()
    }

    func usernamePressed() {
        guard let offer = self.smartWrapper?.getOffer(forLocation: GlobalPositionPullOffers.happyBirthday) else { return }
        self.delegate?.didSelectOffer(offer.entity)
    }
    
    func needDiscreteMode() -> Bool {
        guard let configuration = self.smartWrapper?.configuration else { return false }
        return configuration.discreteMode
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
    
    func didSelect(experience: ExperiencesViewModel) {
        delegate?.didSelectOffer(experience.offer)
    }
    
    func didTapOnProduct(product: PGCellInfo) {
        guard let info = product.info as? ElementEntity else { return }
        switch info.elem {
        case let element as AccountEntity:
            delegate?.didSelectAccount(account: element)
        case let element as CardEntity:
            delegate?.didSelectCard(card: element)
        case let element as FundEntity:
            self.didSelectFund(element)
        case let element as InsuranceSavingEntity:
            if self.enableInsuranceDetail {
                self.delegate?.didSelectInsuranceSaving(insurance: element)
            } else {
                self.presentInsurancesMessage()
            }
        case let element as InsuranceProtectionEntity:
            if self.enableInsuranceDetail {
                self.coordinator.didSelectInsuranceProtection(insurance: element)
            } else {
                self.presentInsurancesMessage()
            }
        case let element as LoanEntity:
            self.delegate?.didSelectLoan(loan: element)
        case let element as PensionEntity:
            self.delegate?.didSelectPension(pension: element)
        case let element as PortfolioEntity:
            if element.productId == "ManagedPortfolio" {
                self.getPortfolioWebViewConfig(portfolio: element, isManaged: true)
            } else if element.productId == "NotManagedPortfolio" {
                self.getPortfolioWebViewConfig(portfolio: element, isManaged: false)
            }
        case let element as StockAccountEntity:
            delegate?.didSelectStockAccount(stockAccount: element)
        case let element as PullOfferCompleteInfo:
            self.delegate?.didSelectOffer(element.entity)
        case let element as MovementCompleteInfo:
            self.delegate?.didSelectAccountMovement(movement: element.movement, in: element.account)
        case let element as DepositEntity:
            self.coordinator.didSelectDeposit(deposit: element)
        case let element as SavingProductEntity:
            delegate?.didSelectSavingProduct(savingProduct: element)
        default:
            break
        }
    }
    
    func didSelectTimeLine() {
        trackEvent(.timeline, parameters: [.pgType: GlobalPositionConstants.smartPgType])
        self.delegate?.didSelectTimeLine()
    }
    
    func didSelectTimeLineOffer() {
        guard let offer = self.smartWrapper?.getOffer(forLocation: GlobalPositionPullOffers.pgTimeline) else {
            return
        }
        self.delegate?.didSelectOffer(offer.entity)
    }
    
    func didSelectedSizeOffer(_ offer: OfferEntity) {
        self.delegate?.didSelectOffer(offer)
    }
        
    func didEndedPGBookmarkScroll() {
        trackEvent(.swipeCarousel, parameters: [.pgType: GlobalPositionConstants.smartPgType])
    }
    
    func logoPressed() {
        if !self.doubleTapping {
            self.doubleTapping = true
            self.updateDiscreteModeState()
        }
    }
    
    func activateCard(_ card: Any) {
        delegate?.didActivateCard(card)
    }
    
    func turnOnCard(_ card: Any) {
        delegate?.didTurnOnCard(card)
    }
    
    func interventionFilterDidSelect(_ filter: PGInterventionFilter) {
        if smartWrapper?.filterDidSelect(filter) ?? false {
            dataManager?.setInterventionFilter(filter)
            refreshInfo()
            view?.reloadCollectionData()
            view?.scrollToTop()
        }
    }
    
    func didSelectAvios() {
        pgSmartCoordinator.goToAviosDetail()
    }
    
    func didPressConfigureGP() {
        localAppConfig.isEnabledConfigureWhatYouSee ? delegate?.didSelectConfigureGPProducts() : view?.showNotAvailableOperation()
    }
    
    func didTapOnAnalysis() {
        self.analysisZone()
    }
    
    func didClosePullOffer(_ pullOffer: Any) {
        guard let pullOffer = pullOffer as? PullOfferCompleteInfo else { return }
        self.dataManager?.didExpireOffer(pullOffer.entity)
        self.smartWrapper?.removePullOffer(pullOffer)
        self.refreshInfo()
        self.view?.reloadCollectionData()
    }
    
    func didSelectWhatsNew() {
        trackEvent(.bubble, parameters: [.pgType: GlobalPositionConstants.smartPgType])
        pgSmartCoordinator.goToWhatsNew()
    }
    
    private func setupExpenses() {
        if let monthInfo = self.monthlyBalance {
            postActionAfterMonthlyBalance(result: monthInfo)
        }
    }
    
    private func setupCurrentBalance(balanceValue: Decimal?, financingValue: Decimal?, discreteMode: Bool, insuranceEnabled: Bool) {
        let balanceAmount: AmountEntity? = balanceValue != nil ? AmountEntity(value: balanceValue!): nil
        let financingAmount: AmountEntity? = financingValue != nil ? AmountEntity(value: financingValue!): nil
        let tooltipText = insuranceEnabled ? "tooltip_text_pgMoneyFinancing" : "tooltip_text_pgMoneyFinancingWithoutInsurance"
        self.view?.configureCurrentBalance(data: CurrentBalanceGraphData(total: balanceAmount, financing: financingAmount, discreteModeActivated: discreteMode, tooltipText: tooltipText))
    }
    
    private func updateDiscreteModeState() {
        dataManager?.getUserPreferencesValues(userId: smartWrapper?.configuration?.userId, { [weak self] response in
            var userPref = response.userPref
            self?.toggleDiscreteMode(userPref: &userPref)
            self?.showDiscreteModeAlert(isEnabled: userPref.isDiscretModeActivated())
            self?.dataManager?.updateUserPreferencesValues(userPrefEntity: userPref)
            self?.reload(with: userPref)
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
    
    private func showDiscreteModeAlert(isEnabled: Bool) {
        let enabledString = "pg_alert_discreteModeActivated"
        let disabledString = "pg_alert_discreteModeOff"
        let message: LocalizedStylableText = self.stringLoader.getString(isEnabled ? enabledString : disabledString)
        view?.showAlert(with: message, messageType: .info)
    }
    
    private func saveDiscreteModeState() {
        guard let discreteModeEnabled = self.discreteModeActivated else { return }
        dataManager?.getUserPreferencesValues(userId: smartWrapper?.configuration?.userId, { [weak self] response in
            let userPref = response.userPref
            userPref.setDiscreteMode(discreteModeIsOn: discreteModeEnabled)
            self?.dataManager?.updateUserPreferencesValues(userPrefEntity: userPref)
        }, failure: { _ in
            
        })
    }
    
    private func postActionAfterMonthlyBalance(result: [MonthlyBalanceRepresentable]) {
        view?.showPendingSolicitudesIfNeeded()
        dataManager?.getUserPreferencesValues(userId: smartWrapper?.configuration?.userId, { [weak self] response in
            guard let strongSelf = self else { return }
            let userBudget = response.userPref.getBudget()
            let userPref = response.userPref
            strongSelf.configureExpenseGraph(result: result, userBudget: userBudget)
            if let whatsNewEnabled = strongSelf.smartWrapper?.configuration?.isWhatsNewZoneEnabled {
                strongSelf.loadWhatsNewView(userPref: userPref, whatsNewEnabled: whatsNewEnabled)
            } else {
                strongSelf.dataManager?.getPGValues({ [weak self] response in
                    self?.loadWhatsNewView(userPref: userPref, whatsNewEnabled: response.isWhatsNewZoneEnabled)
                }, failure: { _ in })
            }
        }, failure: { _ in })
    }
    
    private func configureExpenseGraph(result: [MonthlyBalanceRepresentable], userBudget: Double?) {
        let maximum = result.reduce(0) { (maximum, month) -> Decimal in
            return maximum < month.expense ? month.expense : maximum
        }
        
        var budgetSize: Float = 0.0
        if maximum == 0 {
            budgetSize = 0.7
        } else if let userBudget = userBudget {
            let budgetDecimal = Decimal(userBudget)
            budgetSize = Float(truncating: (budgetDecimal as NSDecimalNumber).dividing(by: NSDecimalNumber(decimal: maximum)))
        } else {
            let budgetDecimal = Decimal(getEditBudgetData(userBudget: userBudget, threeMonthsExpenses: result, resolver: dependenciesResolver).budget)
            budgetSize = Float(truncating: (budgetDecimal as NSDecimalNumber).dividing(by: NSDecimalNumber(decimal: maximum)))
        }
        
        let viewModel = ExpensesGraphViewModel(monthlyBalance: result, budgetSize: budgetSize)
        viewModel.isDiscreteMode = self.needDiscreteMode()
        self.view?.configureExpensesGraph(withData: viewModel)
    }
    
    private func getPGUserValues() {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = resolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        guard let userPref = globalPosition.userPref else { return }
        setPGStyleValues(userPref: userPref)
    }
    
    private func setPGStyleValues(userPref: UserPrefEntity) {
        getOtherOperatives(nil)
        view?.setAvailableActions(Array(availableActions.prefix(4)))
        view?.configureBackgroundView(mode: userPref.getPGColorMode())
    }
    
    private func getIsSearchEnabled() {
        dataManager?.getIsSearchEnabled(with: resolver) { [weak self] response in
            self?.view?.isSearchEnabled = response
        }
    }
}
 
// MARK: - GlobalPositionReloadable

extension PGSmartPresenter: GlobalPositionReloadable {
    func reload(with userPref: UserPrefEntity) {
        dataManager?.getPGValues({ [weak self] response in
            var resp = response
            resp.userPref = userPref
            self?.enableInsuranceDetail = response.enableInsuranceDetail
            self?.setViewInfo(resp)
            self?.setupExpenses()
            self?.loadTopOffer()
            self?.setupCurrentBalance(balanceValue: resp.totalFinance,
                                      financingValue: resp.financingTotal,
                                      discreteMode: userPref.isDiscretModeActivated(),
                                      insuranceEnabled: resp.isInsuranceEnabled)
        }, failure: { _ in })
    }
    func reload() {
        self.delegate?.globalPositionDidReload()
        dataManager?.getPGValues({ [weak self] response in
            self?.enableInsuranceDetail = response.enableInsuranceDetail
            self?.setViewInfo(response)
            self?.setupExpenses()
            self?.loadTopOffer()
            self?.setupCurrentBalance(balanceValue: response.totalFinance,
                                      financingValue: response.financingTotal,
                                      discreteMode: response.userPref?.isDiscretModeActivated() ?? false,
                                      insuranceEnabled: response.isInsuranceEnabled)
            self?.callFavouriteCarouselIfNeeded()
        }, failure: { _ in })
    }
    
    private func presentInsurancesMessage() {
        let accept = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept"), does: nil)
        self.view?.showOldDialog(title: nil, description: self.stringLoader.getString("insurancesDetail_label_error"), acceptAction: accept, cancelAction: nil, isCloseOptionAvailable: false)
    }
}

extension PGSmartPresenter: OtherOperativesHelper {
    var otherOperativesDelegate: OtherOperativesActionDelegate? { delegate }
    var wrapper: OtherOperativesEvaluator? { smartWrapper }
    
    func goToMoreOperateOptions() {
        pgCoordinator.goToMoreOperateOptions()
    }
}

extension PGSmartPresenter: ShortcutsDelegate {
    
    func didSaveChanges(viewModels: [GpOperativesViewModel]) {
        let frequentOperativesKeys: [String] = viewModels.map { $0.type }.map { $0.rawValue }
        reloadAvailableActions(viewModels)
        dataManager?.getUserPreferencesValues(userId: smartWrapper?.configuration?.userId, { [weak self] response in
            guard let strongSelf = self else { return }
            let userPref = response.userPref
            userPref.setFrequentOperativesKeys(frequentOperativesKeys)
            strongSelf.dataManager?.updateUserPreferencesValues(userPrefEntity: userPref)
            }, failure: { _ in })
    }
}

extension PGSmartPresenter: OperativeSelectorLauncher {
    func launch() {
        guard let view = view as? UIViewController, let configuration = smartWrapper?.configuration else { return }
        
        let smartShortcutsViewController = resolver.resolve(for: SmartShortcutsViewController.self)
        smartShortcutsViewController.setData(delegate: self, viewModels: availableActions, gpColorMode: configuration.pgColorMode)
        if #available(iOS 11.0, *) { view.navigationController?.delegate = view as? UINavigationControllerDelegate }
        (view as? PGSmartViewProtocol)?.hidePlusButton()
        view.navigationController?.pushViewController(smartShortcutsViewController, animated: true, completion: {
            view.navigationController?.view.setNeedsLayout()
            view.navigationController?.view.layoutIfNeeded()
        })
        (view as? PGSmartViewProtocol)?.configureForAnimation(actionBarIsHidden: true)
        trackEvent(.moreActions, parameters: [.pgType: GlobalPositionConstants.smartPgType])
    }
    
    func isEnabledMoreOptions() -> Bool {
        return self.localAppConfig.isEnabledPlusButtonPG
    }
}

extension PGSmartPresenter: AutomaticScreenActionTrackable {
    
    var trackerManager: TrackerManager {
        return resolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: GlobalPositionPage {
        let emmaTrackEventList: EmmaTrackEventListProtocol = self.resolver.resolve()
        let emmaToken = emmaTrackEventList.globalPositionEventID
        return GlobalPositionPage(emmaToken: emmaToken)
    }
    
    func getTrackParameters() -> [String: String]? {
        [TrackerDimension.pgType.key: GlobalPositionConstants.smartPgType]
    }
    
    private func trackOperative(_ operative: PGFrequentOperativeOption) {
        guard
            (operative != .contract || self.wrapper?.getOffer(forLocation: "OPERAR_PG") == nil),
            let trackName = operative.trackName,
            let actionType = GlobalPositionPage.ActionType(rawValue: trackName)
        else { return }
        trackEvent(actionType, parameters: [.pgType: GlobalPositionConstants.smartPgType])
    }
}

public struct CurrentBalanceGraphData {
    let total: AmountEntity?
    let financing: AmountEntity?
    let discreteModeActivated: Bool
    let tooltipText: String
}

extension PGSmartPresenter: EditBudgetHelper {
    
    func didTapOnEditBudget(originView: UIView) {
        trackEvent(.editExpenses, parameters: [.pgType: GlobalPositionConstants.smartPgType])
        dataManager?.getUserPreferencesValues(userId: smartWrapper?.configuration?.userId, { [weak self] response in
            guard let strongSelf = self else { return }
            let userBudget = response.userPref.getBudget()
            let budget = strongSelf.getEditBudgetData(userBudget: userBudget,
                                                      threeMonthsExpenses: strongSelf.monthlyBalance,
                                                      resolver: strongSelf.dependenciesResolver)
            
            strongSelf.view?.showEditBudgetView(originView: originView, editBudget: budget, delegate: self)
        }, failure: { _ in })
    }
}

extension PGSmartPresenter: BudgetBubbleViewProtocol {
    func didPressSaveButton(budget: Double) {
        dataManager?.getUserPreferencesValues(userId: smartWrapper?.configuration?.userId, { [weak self] response in
            guard let strongSelf = self else { return }
            let userPref = response.userPref
            userPref.setBudget(budget)
            strongSelf.dataManager?.updateUserPreferencesValues(userPrefEntity: userPref)
            if let monthInfo = self?.monthlyBalance {
                self?.configureExpenseGraph(result: monthInfo, userBudget: budget)
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

// MARK: - Private methods

private extension PGSmartPresenter {
    func loadTopOffer() {
        dataManager?.getLoanSimulatorLimits { [weak self] simulationEntity in
            guard let self = self else { return }
            if let loanLimits = simulationEntity {
                self.smartWrapper?.setLoanSimulatorLimits(limits: loanLimits)
            } else {
                self.smartWrapper?.setLoanSimulatorLimits(limits: nil)
            }
            self.refreshInfo()
        }
    }
    
    func getLoanBannerLimitsIfNeeded() {
        dataManager?.getLoanBannerLimits { [weak self] bannerEntity in
            guard let self = self else { return }
            if let loanBanner = bannerEntity {
                self.smartWrapper?.setLoanBannerLimits(limits: loanBanner)
                self.callFavouriteCarouselIfNeeded()
                self.refreshInfo()
            }
        }
    }
    
    func setBookmarks() {
        let timelineType: PGBookmarkTimelineTypeViewModel
        let addBookmarks: Bool
        if self.isTimelineEnabled == true {
            timelineType = .timeline
            addBookmarks = true
        } else if let timelineLocation = self.smartWrapper?.pullOfferCandidates.filter({ $0.key.stringTag == "PG_TIMELINE" }).first {
            timelineType = .offer(url: timelineLocation.value.banner?.url)
            addBookmarks = true
        } else if bookmarkPullOffers.count > 0 {
            timelineType = .offer(url: nil)
            addBookmarks = true
        } else {
            timelineType = .offer(url: nil)
            addBookmarks = self.isPregrantedSimulatorEnabled == true  && self.loanViewModel != nil
        }
        let bookmark: PGBookmarkTableViewModel?
        if addBookmarks {
            let sizeOfferViewModels = createSizeOfferViewModels()
            bookmark = PGBookmarkTableViewModel(resolver: self.resolver, timelineType: timelineType, loanViewModel: self.loanViewModel, sizeOfferViewModel: sizeOfferViewModels)
        } else {
            bookmark = nil
        }
        self.view?.setBookmarks(bookmark)
    }
    
    func setViewInfo(_ info: GetPGUseCaseOkOutput) {
        setSantanderLogo(info)
        smartWrapper?.setGPValues(info, filter: dataManager?.getInterventionFilter() ?? .all)
        view?.setVisibilityBalanceCarousel(info.userPref?.isChartModeActivated() == true)
        
        getMovementsOfAccounts(info.visibleAccounts)
        getMovementsOfCards(info.cards)
        guard let configuration = smartWrapper?.configuration else { return }
        view?.configureBackgroundView(mode: configuration.pgColorMode)
        view?.setUserName()
        getOtherOperatives(info.frequentOperatives)
        if let filter = smartWrapper?.interventionFilterSelected {
            view?.enableInterventionFilters(configuration.isPb)
            view?.setCurrentInterventionFilter(filter)
        }
        if let products = self.smartWrapper?.toCellsDictionary() {
            view?.setSmartProducts(products: products)
            view?.reloadCollectionData()
        }
        if let offers = self.smartWrapper?.getTopOfferCells() {
            self.view?.setTopOfferCarousel(offers: offers)
        }
        self.isTimelineEnabled = info.isTimelineEnabled
        self.isPregrantedSimulatorEnabled = info.isPregrantedSimulatorEnabled
        self.bookmarkPullOffers = info.bookmarkPullOffers
        self.setBookmarks()
        view?.setAvailableActions(Array(availableActions.prefix(4)))
        view?.setVisibilityOnePayCarousel(visible: configuration.isSmartOnePayCarouselEnabled)
        view?.setEnabledAviosBanner(configuration.shouldShowAviosBanner)
        self.view?.updateSantanderLogoAccessibility(discretMode: info.userPref?.isDiscretModeActivated() ?? false)
    }
    
    func setSantanderLogo(_ info: GetPGUseCaseOkOutput) {
        if let userSegmentDelegate: UserSegmentProtocol = self.dependenciesResolver.resolve(forOptionalType: UserSegmentProtocol.self) {
            userSegmentDelegate.getUserSegment { [weak self] result, _  in
                guard let self = self else { return }
                let smartImgName = result.segmentImage() == "icnSantander" ? "White" : "Smart"
                self.view?.setSantanderLogo(result.segmentImage() + smartImgName)
            }
        } else {
            let smartImgName = info.segmentType.segmentImage() == "icnSantander" ? "White" : "Smart"
            view?.setSantanderLogo(info.segmentType.segmentImage() + smartImgName)
        }
    }

    func parseMontlyExpenses(_ expenses: [MonthlyBalanceRepresentable]) -> ExpensesParsedResults {
        let timeManager = resolver.resolve(for: TimeManager.self)
        let thisMonth = timeManager.toString(date: Date(), outputFormat: .MMM) ?? ""
        let parsedXpenses: [MonthlyBalanceSmartPG] = expenses.map {
            let month = timeManager.toString(date: $0.date, outputFormat: .MMM) ?? ""
            let monthInfo = timeManager.toString(date: $0.date, outputFormat: .MMMM) ?? ""
            return MonthlyBalanceSmartPG(month: month, monthInfo: monthInfo, amount: $0.expense)
        }
        return (expenses: parsedXpenses, currentMonth: thisMonth)
    }
    
    func getMovementsOfAccounts(_ accounts: [AccountEntity]?) {
        accounts?.forEach {
            getMovementsOfAccount($0)
        }
    }
    
    func getMovementsOfAccount(_ account: AccountEntity) {
        dataManager?.getUnreadMovementsOfAccount(account, { [weak self] response in
            if let pos = self?.smartWrapper?.setNotification(response.newMovements, in: account) {
                self?.refreshRows(pos)
            }
            }, failure: { _ in
        })
    }
    
    func getMovementsOfCards(_ cards: [CardEntity]?) {
        cards?.forEach {
            getMovementsOfCard($0)
        }
    }
    
    func getMovementsOfCard(_ card: CardEntity) {
        dataManager?.getUnreadMovementsOfCard(card, { [weak self] response in
            if let pos = self?.smartWrapper?.setNotification(response.newMovements, in: card) {
                self?.refreshRows(pos)
            }
            }, failure: { _ in })
    }
    
    func refreshRows(_ row: Int) {
        refreshInfo()
        view?.reloadCollectionRow(row)
    }
    
    func refreshInfo() {
        if let products = smartWrapper?.toCellsDictionary() {
            view?.setSmartProducts(products: products)
        }
        if let offers = self.smartWrapper?.getTopOfferCells() {
            self.view?.setTopOfferCarousel(offers: offers)
        }
        if let filter = smartWrapper?.interventionFilterSelected {
            view?.setCurrentInterventionFilter(filter)
        }
    }
    
    func reloadAvailableActions(_ viewModels: [GpOperativesViewModel]) {
        view?.setAvailableActions(Array(viewModels.prefix(4)))
        getOtherOperatives(viewModels.map { $0.type })
    }
    
    // If location mini pfm, go to location, if not, go to analysis
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
    
    func createSizeOfferViewModels() -> [SizeOfferViewModel] {
        let sizeViewModels = bookmarkPullOffers.map { (bookmarkEntity, offers) -> SizeOfferViewModel in
            return SizeOfferViewModel(title: bookmarkEntity.title ?? "", size: bookmarkEntity.size, offers: offers)
        }
        return sizeViewModels
    }
    
    func loadWhatsNewView(userPref: UserPrefEntity, whatsNewEnabled: Bool) {
        self.view?.isWhatsNewBigBubbleVisible(userPref.isWhatsNewBigBubbleVisible(),
                                              whatsNewEnabled: whatsNewEnabled,
                                              completion: {
                                                userPref.setWhatsNewBigBubbleVisible(true)
                                                self.dataManager?.updateUserPreferencesValues(userPrefEntity: userPref)
        })
    }
    
    func checkFrequentOperativeOptionSelected() {
        guard let frequentOperativeOptionSelected = frequentOperativeOptionSelected else {
            return
        }
        switch frequentOperativeOptionSelected.getAction() {
        case .core(option: let option):
            if let otherOperativesDelegate = self.dependenciesResolver.resolve(forOptionalType: OtherOperativesModifierProtocol.self),
               !otherOperativesDelegate.isOtherOperativeEnabled(option) {
                self.view?.showNotAvailableOperation()
            } else {
                self.navigateTo(operative: option)
            }
        case .custom(action: let action):
            if let location = frequentOperativeOptionSelected.getLocation(),
               let offer = wrapper?.getOffer(forLocation: location) {
                self.delegate?.didSelectOffer(offer.entity)
            } else {
                action()
            }
        }
        self.frequentOperativeOptionSelected = nil
    }
    
    func didSelectFund(_ fund: FundEntity) {
        if self.dependenciesResolver.resolve(for: LocalAppConfig.self).isEnabledfundWebView {
            self.view?.showNotAvailableOperation()
        } else {
            self.coordinator.didSelectFund(fund: fund)
        }
    }
}

private extension PGSmartPresenter {
    // MARK: - Favourite Carousel
    func configureFavouriteCarousel(_ info: GetPGUseCaseOkOutput) {
        guard let strongView = self.view else { return }
        guard info.isSmartOnePayCarouselEnabled else {
            self.isFavouriteCarouselEnabled = false
            strongView.setVisibilityOnePayCarousel(visible: false)
            return
        }
        self.isFavouriteCarouselEnabled = true
        self.view?.setVisibilityOnePayCarousel(visible: true)
    }
    
    func loadFavouriteCarousel() {
        guard let strongView = self.view else { return }
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        self.dataManager?.getFavouritesContacts({ [weak self] response in
            guard let strongSelf = self else { return }
            let onePayPGViewModel = OnePayPGViewModel(response.contactEntityList, baseUrl: strongSelf.baseURLProvider.baseURL, colorsEngine: colorsEngine)
            let onePayPGInfoList = onePayPGViewModel.loadDataInFavouriteCarousel(response.contactEntityList)
            if onePayPGInfoList.count == OnePayPGConfiguration.defaultPills.count {
                strongSelf.cacheDefaultPills = onePayPGInfoList
            }
            DispatchQueue.main.async {
                strongView.setFavouriteCarousel(onePayPGInfoList)
            }
            }, failure: { _ in
                let defaultPills = OnePayPGConfiguration.defaultPills
                self.view?.setFavouriteCarousel(defaultPills)
        })
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
                        self.view?.setFavouriteCarousel(updatedPills)
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
}

private extension PGSmartPresenter {
    
    func loadMonthlyBalance() {
        dataManager?.getMonthlyBalance { [weak self] months in
            guard let self = self else { return }
            if months.count > 0 {
                self.monthlyBalance = months
                self.dataManager?.getUserPreferencesValues(userId: self.smartWrapper?.configuration?.userId, { [weak self] userPrefs in
                    guard let self = self else { return }
                    self.configureExpenseGraph(result: months, userBudget: userPrefs.userPref.getBudget())
                }, failure: { [weak self] _ in
                    self?.configureExpenseGraph(result: months, userBudget: 0.7)
                })
            } else {
                self.setMonthlyBalanceToZero()
            }
            self.postActionAfterMonthlyBalance(result: months)
        }
    }
    
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
    
    func setMonthlyBalanceToZero() {
        let monthlyBalance: [MonthlyBalanceRepresentable] = [
            DefaultMonthlyBalance(date: Date().getDateByAdding(months: -2, ignoreHours: true), expense: 0.0, income: 0.0),
            DefaultMonthlyBalance(date: Date().getDateByAdding(months: -1, ignoreHours: true), expense: 0.0, income: 0.0),
            DefaultMonthlyBalance(date: Date(), expense: 0.0, income: 0.0)]
        self.monthlyBalance = monthlyBalance
        let viewModel = ExpensesGraphViewModel(monthlyBalance: monthlyBalance, budgetSize: 0.7)
        viewModel.isDiscreteMode = self.needDiscreteMode()
        self.configureExpenseGraph(result: monthlyBalance, userBudget: 0.7)
    }
    
    func isPregrantedOfferExpired(_ offerId: String) {
        let empty = self.smartWrapper?.isPregrantedOfferExpired(offerId)
        (empty ?? true) ? self.update() : self.refreshInfo()
    }
    
    func update() {
        self.refreshInfo()
        self.view?.reloadCarousel()
    }
}

extension PGSmartPresenter: TopOfferCarouselViewDelegate {
    func didSelectPregrantedBanner(_ offer: ExpirableOfferEntity?) {
        self.trackEvent(.pregrantedBanner, parameters: [.pgType: GlobalPositionConstants.smartPgType])
        guard let offer = offer else { return }
        didSelectPullOffer(offer)
    }
    
    func didSelectPullOffer(_ info: ExpirableOfferEntity) {
        self.delegate?.didSelectOffer(info)
        guard info.expiresOnClick, let offerId = info.id else { return }
        self.dataManager?.disableOffer(offerId, { [weak self] in
            self?.isPregrantedOfferExpired(offerId)
        })
    }
}
