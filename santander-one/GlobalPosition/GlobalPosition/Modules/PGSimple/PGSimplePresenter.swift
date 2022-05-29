import CoreFoundationLib
import CoreDomain

protocol PGSimplePresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: PGSimpleViewProtocol? { get set }
    var dataManager: PGDataManagerProtocol? { get set }
    func viewDidLoad()
    func viewDidAppear()
    func viewWillAppear()
    func viewDidDisappear()
    func mailDidPressed()
    func searchDidPressed()
    func drawerDidPressed()
    func usernameDidPressed()
    func balanceDidPressed()
    func reload()
    func setController(_ controller: PGSimpleTableViewController)
    func didSelectWhatsNew()
    func didSelectOffer(offer: OfferEntity)
    func didPressLogo()
}

final class PGSimplePresenter: PGSimpleTableViewControllerDelegate {
    private let resolver: DependenciesResolver
    var dependenciesResolver: DependenciesResolver {
        return self.resolver
    }
    internal weak var view: PGSimpleViewProtocol?
    private var delegate: GlobalPositionModuleCoordinatorDelegate? {
        return resolver.resolve(for: GlobalPositionModuleCoordinatorDelegate.self)
    }
    internal weak var dataManager: PGDataManagerProtocol?
    
    private var controller: PGSimpleTableViewController? {
        didSet {
            controller?.delegate = self
        }
    }
    
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().globalPosition
    }
    
    private var pgCoordinator: PGClassicCoordinator {
        return resolver.resolve(for: PGClassicCoordinator.self)
    }
    
    private var pgSimpleCoordinator: PGSimpleCoordinator {
        return resolver.resolve(for: PGSimpleCoordinator.self)
    }
    
    private var stringLoader: StringLoader {
        return self.resolver.resolve(for: StringLoader.self)
    }
    
    private var localAppConfig: LocalAppConfig {
        self.resolver.resolve(for: LocalAppConfig.self)
    }
    
    private var coordinator: GlobalPositionModuleCoordinatorProtocol {
        return self.resolver.resolve(for: GlobalPositionModuleCoordinatorProtocol.self)
    }
    
    private lazy var simpleGlobalPositionModifier: SimpleGlobalPositionModifierProtocol? = {
        self.dependenciesResolver.resolve(forOptionalType: SimpleGlobalPositionModifierProtocol.self)
    }()
    
    private var simpleGlobalPositionActionsUseCase: GetSimpleGlobalPositionActionsUseCaseProtocol? {
        return dependenciesResolver.resolve(forOptionalType: GetSimpleGlobalPositionActionsUseCaseProtocol.self)
    }
    
    private var simpleWrapper: SimpleGlobalPositionWrapperProtocol?
    private var sectionsToUpdate: Set<Int> = []
    private let semaphore = DispatchSemaphore(value: 1)
    private var contractOffer: OfferEntity?
    private var doubleTapping: Bool = false
    private var discreteModeActivated: Bool?
    private var enableInsuranceDetail: Bool = false
    var availableActions: [GpOperativesViewModel] = []
    private var isEnabledWhatsNew: Bool = false
    
    private var portfolioWebViewConfigUseCase: GetPortfolioWebViewConfigurationUseCase {
        return self.resolver.resolve(for: GetPortfolioWebViewConfigurationUseCase.self)
    }
    
    init(resolver: DependenciesResolver) {
        self.resolver = resolver
        let globalPositionReloadEngine = self.resolver.resolve(for: GlobalPositionReloadEngine.self)
        globalPositionReloadEngine.removeList()
        globalPositionReloadEngine.add(self)
        simpleWrapper = resolver.resolve(for: SimpleGlobalPositionWrapperProtocol.self)
    }
    
    private func update() {
        refreshInfo()
        controller?.reloadAllTable()
    }
    
    private func refreshInfo() {
        guard let wrapper = simpleWrapper else { return }
        controller?.cellsInfo = wrapper.toCellsDictionary()
    }
    
    // MARK: - PGSimpleTableViewControllerDelegate methods
    
    func didSelectInfo(_ info: ElementEntity?) {
        guard let info = info else { return }
        if let account = info.elem as? AccountEntity {
            self.didSelectAccount(account)
        } else if let card = info.elem as? CardEntity {
            self.delegate?.didSelectCard(card: card)
        } else if let fund = info.elem as? FundEntity {
            self.didSelectFund(fund)
        } else if let insurance = info.elem as? InsuranceSavingEntity {
            self.didSelectInsurance(insurance)
        } else if let insurance = info.elem as? InsuranceProtectionEntity {
            self.didSelectInsurance(insurance)
        } else if let loan = info.elem as? LoanEntity {
            delegate?.didSelectLoan(loan: loan)
        } else if let pension = info.elem as? PensionEntity {
            delegate?.didSelectPension(pension: pension)
        } else if let portfolio = info.elem as? PortfolioEntity {
            self.didSelectPortfolio(portfolio)
        } else if let stockAccount = info.elem as? StockAccountEntity {
            delegate?.didSelectStockAccount(stockAccount: stockAccount)
        } else if let offer = info.elem as? PullOfferCompleteInfo {
            delegate?.didSelectOffer(offer.entity)
        } else if let movement = info.elem as? MovementCompleteInfo {
            delegate?.didSelectAccountMovement(movement: movement.movement, in: movement.account)
        } else if let deposit = info.elem as? DepositEntity {
            self.coordinator.didSelectDeposit(deposit: deposit)
        } else if let savingProduct = info.elem as? SavingProductEntity {
            delegate?.didSelectSavingProduct(savingProduct: savingProduct)
        }
    }
    
    func didSelectPregrantedBanner(_ offer: ExpirableOfferEntity?) {
        trackEvent(.pregrantedBanner, parameters: [.pgType: GlobalPositionConstants.simplePgType])
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
        let empty = simpleWrapper?.isPregrantedOfferExpired(offerId)
        (empty ?? true) ? update() : refreshInfo()
    }
    
    func didSelectPullOffer(_ info: PullOfferCompleteInfo) {
        delegate?.didSelectOffer(info.entity)
    }
    
    func didClosePullOffer(_ pullOffer: Any) {
        guard let pullOffer = pullOffer as? PullOfferCompleteInfo else { return }
        self.dataManager?.didExpireOffer(pullOffer.entity)
        simpleWrapper?.removePullOffer(pullOffer)
        update()
    }
    
    func resizePullOffer(_ pullOffer: Any, to height: CGFloat) {
        simpleWrapper?.resizePullOffer(pullOffer, to: height)
        update()
    }
    
    func activateCard(_ card: Any) {
        delegate?.didActivateCard(card)
        let eventId = (card as? CardEntity)?.isContractBlocked == true ? Constants.clickUnfreezeCard : Constants.clickActivateCard
        trackerManager.trackEvent(screenId: trackerPage.page, eventId: eventId, extraParameters: getTrackParameters() ?? [:])
    }
    
    func turnOnCard(_ card: Any) {
        delegate?.didTurnOnCard(card)
    }
    
    func switchFilterHeader(_ idx: Int) {
        if simpleWrapper?.switchFilterHeader() != nil {
            refreshInfo()
            controller?.insertInSection(idx)
            controller?.scrollTo(idx, at: .top)
        }
    }
    
    func filterDidSelect(_ filter: PGInterventionFilter) {
        if simpleWrapper?.filterDidSelect(filter) ?? false {
            dataManager?.setInterventionFilter(filter)
            update()
            controller?.scrollToTop()
        }
    }
    
    func didPressAvios() {
        pgCoordinator.goToAviosDetail()
    }
    
    func didPressConfigureGP() {
        localAppConfig.isEnabledConfigureWhatYouSee ? delegate?.didSelectConfigureGPProducts() : view?.showNotAvailableOperation()
    }
    
    func didScroll() {
        self.view?.showAndHideWhatsNewBubble(isEnabled: isEnabledWhatsNew)
    }
}

// MARK: - PGSimplePresenterProtocol

extension PGSimplePresenter: PGSimplePresenterProtocol {
    
    func setController(_ controller: PGSimpleTableViewController) { self.controller = controller }
    
    private func loadWhatsNewView(_ userPref: UserPrefEntity?, whatsNewEnabled: Bool) {
        self.isEnabledWhatsNew = whatsNewEnabled
        view?.isWhatsNewBigBubbleVisible(userPref?.isWhatsNewBigBubbleVisible() ?? false, whatsNewEnabled: whatsNewEnabled, completion: {
            guard let userPref = userPref else { return }
            userPref.setWhatsNewBigBubbleVisible(true)
            self.dataManager?.updateUserPreferencesValues(userPrefEntity: userPref)
        })
    }
    
    func viewDidLoad() {
        view?.configView(simpleGlobalPositionModifier?.isYourMoneyVisible ?? true,
                         isConfigureWhatYouSeeVisible: simpleGlobalPositionModifier?.isConfigureWhatYouSeeVisible ?? true)
        _ = self.resolver.resolve(for: DeepLinkManagerProtocol.self).isDeepLinkScheduled()
        getIsSearchEnabled()
        delegate?.globalPositionDidLoad()
        dataManager?.getPGValues({ [weak self] response in
            self?.enableInsuranceDetail = response.enableInsuranceDetail
            self?.setViewInfo(response)
            self?.update()
            self?.loadTopOffer()
            self?.loadWhatsNewView(response.userPref, whatsNewEnabled: response.isWhatsNewZoneEnabled)
            self?.getMovementsOfAccounts(response.visibleAccounts, cards: response.cards)
            self?.view?.showPendingSolicitudesIfNeeded()
        }, failure: { _ in })
        trackScreen()
    }
    
    func viewDidAppear() {
        self.delegate?.globalPositionDidAppear()
        self.view?.updatePendingSolicitudes()
    }
    
    func viewWillAppear() {
        dataManager?.getPGValues({ [weak self] response in
            self?.simpleWrapper?.refreshUserPref(response)
            self?.setUserName()
            self?.getMovementsOfAccounts(response.visibleAccounts, cards: response.cards)
            }, failure: { _ in })
        getLoanBannerLimitsIfNeeded()
    }
    
    func viewDidDisappear() {
        self.delegate?.globalPositionDidDisappear()
    }
    
    func mailDidPressed() { delegate?.didSelectMail() }
    func searchDidPressed() { delegate?.didSelectSearch() }
    func drawerDidPressed() { delegate?.didSelectMenu() }
    func usernameDidPressed() {
        let pullOfferLocation = PullOfferLocation(stringTag: GlobalPositionPullOffers.happyBirthday, hasBanner: false, pageForMetrics: GlobalPositionPage().page)
        guard let offer = self.simpleWrapper?.getPullOfferLocation(for: pullOfferLocation.stringTag) else { return }
        self.delegate?.didSelectOffer(offer)
    }
    
    func balanceDidPressed() {
        view?.showBottomSheet(titleKey: "pg_label_totMoney", bodyKey: "tooltip_text_moneyFinancing")
    }
    
    func didSelectWhatsNew() {
        trackEvent(.bubble, parameters: [.pgType: GlobalPositionConstants.simplePgType])
        pgSimpleCoordinator.goToWhatsNew()
    }
    
    func didSelectOffer(offer: OfferEntity) {
        self.delegate?.didSelectOffer(offer)
    }
    
    func didPressLogo() {
        if !self.doubleTapping {
            self.doubleTapping = true
            self.updateDiscreteModeState()
        }
    }
    
    // MARK: - privateMethods
    
    private func setViewInfo(_ info: GetPGUseCaseOkOutput) {
        simpleWrapper?.setGPValues(info, filter: dataManager?.getInterventionFilter() ?? .all)
        let countriesOperatives: [PGFrequentOperativeOptionProtocol]? = simpleWrapper?.getFrequentOperatives()
        let operativesProvider = SimplePGFrequentOperativeOptionValueProvider()
        getOtherOperatives(countriesOperatives, operativesProvider)
        self.setUserName()
        controller?.discreteModeEnabled = info.userPref?.isDiscretModeActivated() ?? false
        self.view?.updateSantanderLogoAccessibility(discretMode: info.userPref?.isDiscretModeActivated() ?? false)
        view?.setDiscreteModeHeader(info.userPref?.isDiscretModeActivated() ?? false)
        setSantanderLogo(info)
        setCountryActions()
    }
    
    private func setCountryActions() {
            guard let simpleGlobalPositionActionsUseCase = simpleGlobalPositionActionsUseCase else {
                self.view?.setAvailableActions(Array(availableActions.prefix(4)),
                                               areActionsHidden: self.simpleGlobalPositionModifier?.areShortcutsVisible == false)
                return
            }
            Scenario(useCase: simpleGlobalPositionActionsUseCase, input: availableActions)
                .execute(on: self.dependenciesResolver.resolve())
                .onSuccess { output in
                    self.view?.setAvailableActions(Array(output.actions.prefix(4)),
                                                   areActionsHidden: self.simpleGlobalPositionModifier?.areShortcutsVisible == false)
                }
        }
    
    private func presentInsurancesMessage() {
        let accept = DialogButtonComponents(titled: localized("generic_button_accept"), does: nil)
        self.view?.showOldDialog(title: nil, description: localized("insurancesDetail_label_error"), acceptAction: accept, cancelAction: nil, isCloseOptionAvailable: false)
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
    
    private func getMovementsOfAccounts(_ accounts: [AccountEntity]?, cards: [CardEntity]?) {
        accounts?.forEach { getMovementsForAccount($0) }
        cards?.forEach { getMovementsForCard($0) }
    }
    
    private func getMovementsForAccount(_ account: AccountEntity) {
        dataManager?.getUnreadMovementsOfAccount(account, { [weak self] (response) in
            self?.semaphore.wait()
            if let sec = self?.simpleWrapper?.setMovements(response.newMovements, in: account) {
                self?.refreshSection(sec)
            }
            self?.semaphore.signal()
            }, failure: { _ in
                
        })
    }
    
    private func getMovementsForCard(_ card: CardEntity) {
        dataManager?.getUnreadMovementsOfCard(card, { [weak self] (response) in
            self?.semaphore.wait()
            if let sec = self?.simpleWrapper?.setMovements(response.newMovements, in: card) {
                self?.refreshSection(sec)
            }
            self?.semaphore.signal()
            }, failure: { _ in
        })
    }
    
    private func setState(_ state: PGMovementsNoticesCellState, in account: AccountEntity) {
        guard let sec = simpleWrapper?.setAccountState(account, state: state) else { return }
        refreshSection(sec)
    }
    
    private func refreshSection(_ sec: Int) {
        refreshInfo()
        controller?.insertInSection(sec)
    }
    
    private func getIsSearchEnabled() {
        dataManager?.getIsSearchEnabled(with: resolver) { [weak self] response in
            self?.view?.isSearchEnabled = response
        }
    }
    
    private func updateDiscreteModeState() {
        dataManager?.getUserPreferencesValues(userId: simpleWrapper?.configuration?.userId, { [weak self] response in
            var userPref = response.userPref
            self?.toggleDiscreteMode(&userPref)
            let discreteModeActivated = self?.discreteModeActivated ?? userPref.isDiscretModeActivated()
            self?.toggleDiscreteModeAppearance(discreteModeActivated)
            self?.showDiscreteModeAlert(isEnabled: discreteModeActivated)
            self?.dataManager?.updateUserPreferencesValues(userPrefEntity: userPref)
            self?.update()
            self?.doubleTapping = false
            }, failure: { [weak self] _ in
                self?.doubleTapping = false
        })
    }
    
    func toggleDiscreteMode(_ userPref: inout UserPrefEntity) {
        let isDiscreteModeEnabled = self.discreteModeActivated ?? userPref.isDiscretModeActivated()
        self.discreteModeActivated = !isDiscreteModeEnabled
        userPref.setDiscreteMode(discreteModeIsOn: !isDiscreteModeEnabled)
        self.view?.updateSantanderLogoAccessibility(discretMode: !isDiscreteModeEnabled)
    }
    
    func toggleDiscreteModeAppearance(_ discreteModeActivated: Bool) {
        self.controller?.discreteModeEnabled = discreteModeActivated
        view?.setDiscreteModeHeader(discreteModeActivated)
    }
    
    func showDiscreteModeAlert(isEnabled: Bool) {
        let enabledString = "pg_alert_discreteModeActivated"
        let disabledString = "pg_alert_discreteModeOff"
        let message: LocalizedStylableText = self.stringLoader.getString(isEnabled ? enabledString : disabledString)
        view?.showAlert(with: message, messageType: .info)
    }
}

// MARK: - GlobalPositionReloadable

extension PGSimplePresenter: GlobalPositionReloadable {
    
    func reload() {
        self.delegate?.globalPositionDidReload()
        self.dataManager?.getPGValues({ [weak self] response in
            self?.enableInsuranceDetail = response.enableInsuranceDetail
            self?.setViewInfo(response)
            self?.update()
            self?.getMovementsOfAccounts(response.visibleAccounts, cards: response.cards)
            self?.loadTopOffer()
            }, failure: { _ in })
    }
}

extension PGSimplePresenter: AutomaticScreenActionTrackable {
    
    var trackerManager: TrackerManager {
        return resolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: GlobalPositionPage {
        let emmaTrackEventList: EmmaTrackEventListProtocol = self.resolver.resolve()
        let emmaToken = emmaTrackEventList.globalPositionEventID
        return GlobalPositionPage(emmaToken: emmaToken)
    }
    
    func getTrackParameters() -> [String: String]? {
        [TrackerDimension.pgType.key: GlobalPositionConstants.simplePgType]
    }
}

private extension PGSimplePresenter {
    
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
    
    func loadTopOffer() {
        guard controller?.cellsInfo != nil,
              locations.contains(where: { $0.stringTag == GlobalPositionPullOffers.loansSimulator })
        else { return }
        dataManager?.getLoanSimulatorLimits { [weak self] simulationEntity in
            guard let self = self else { return }
            if let loanLimits = simulationEntity {
                self.simpleWrapper?.setLoanSimulatorLimits(limits: loanLimits)
            } else {
                self.simpleWrapper?.setLoanSimulatorLimits(limits: nil)
            }
            self.update()
        }
    }
    
    func getLoanBannerLimitsIfNeeded() {
        dataManager?.getLoanBannerLimits { [weak self] bannerEntity in
            guard let self = self else { return }
            if let loanBanner = bannerEntity {
                self.simpleWrapper?.setLoanBannerLimits(limits: loanBanner)
                self.update()
            }
        }
    }
    
    func setUserName() {
        self.view?.setUserName(
            simpleWrapper?.configuration?.userName ?? "",
            amount: simpleWrapper?.configuration?.userMoney,
            birthDay: Calendar.current.isDateInToday(simpleWrapper?.configuration?.userBirthday ?? Date(timeIntervalSince1970: 0.0)),
            isMoneyVisible: simpleGlobalPositionModifier?.isYourMoneyVisible ?? true
        )
    }
    
    func didSelectAccount(_ account: AccountEntity) {
        guard self.simpleGlobalPositionModifier?.isHomeAccountAvailable != false else {
            self.view?.showNotAvailableOperation()
            return
        }
        self.delegate?.didSelectAccount(account: account)
    }
    
    func didSelectFund(_ fund: FundEntity) {
        if self.dependenciesResolver.resolve(for: LocalAppConfig.self).isEnabledfundWebView {
            self.view?.showNotAvailableOperation()
        } else {
            self.coordinator.didSelectFund(fund: fund)
        }
    }
    
    func didSelectInsurance(_ insurance: InsuranceProtectionEntity) {
        if self.enableInsuranceDetail {
            guard self.simpleGlobalPositionModifier?.isHomeProtectionInsuranceAvailable != false else {
                self.view?.showNotAvailableOperation()
                return
            }
            coordinator.didSelectInsuranceProtection(insurance: insurance)
        } else {
            self.presentInsurancesMessage()
        }
    }
    
    func didSelectInsurance(_ insurance: InsuranceSavingEntity) {
        if self.enableInsuranceDetail {
            guard self.simpleGlobalPositionModifier?.isHomeSavingInsuranceAvailable != false else {
                self.view?.showNotAvailableOperation()
                return
            }
            delegate?.didSelectInsuranceSaving(insurance: insurance)
        } else {
            self.presentInsurancesMessage()
        }
    }
    
    func didSelectPortfolio(_ portfolio: PortfolioEntity) {
        guard self.simpleGlobalPositionModifier?.isHomePortfolioAvailable != false else {
            self.view?.showNotAvailableOperation()
            return
        }
        if portfolio.productId == Constants.managedPortfolio {
            self.getPortfolioWebViewConfig(portfolio: portfolio, isManaged: true)
        } else if portfolio.productId == Constants.notManagedPortfolio {
            self.getPortfolioWebViewConfig(portfolio: portfolio, isManaged: false)
        }
    }
}

extension PGSimplePresenter: OtherOperativesHelper {
    
    var otherOperativesDelegate: OtherOperativesActionDelegate? { delegate }
    var wrapper: OtherOperativesEvaluator? { simpleWrapper }
    
    func didSelectAction(_ action: PGFrequentOperativeOptionProtocol, _ entity: Void) {
        switch action.getAction() {
        case .core(option: let option):
            trackOperative(option)
            navigateTo(operative: option)
        case .custom(action: let action):
            action()
        }
    }
        
    func goToMoreOperateOptions() {
        pgCoordinator.goToMoreOperateOptions()
    }
    
    func trackOperative(_ operative: PGFrequentOperativeOption) {
        guard operative != .contract || self.wrapper?.getOffer(forLocation: "OPERAR_PG") == nil else {
            return
        }
        guard
            let trackName = operative.trackName,
            let actionType = GlobalPositionPage.ActionType(rawValue: trackName)
        else { return }
        trackEvent(actionType, parameters: [.pgType: GlobalPositionConstants.simplePgType])
    }
}

// MARK: - Constants

private extension PGSimplePresenter {
    enum Constants {
        static let managedPortfolio = "ManagedPortfolio"
        static let notManagedPortfolio = "NotManagedPortfolio"
        static let clickActivateCard = "click_activate_card"
        static let clickUnfreezeCard = "click_unfreeze_card"
    }
}
