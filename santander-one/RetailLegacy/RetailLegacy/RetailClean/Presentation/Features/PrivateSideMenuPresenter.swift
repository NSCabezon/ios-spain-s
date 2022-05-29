import CoreFoundationLib
import Menu
import CoreDomain
import OpenCombine

public protocol PrivateSideMenuModifier {
    func getConfiguration(globalPosition: CoreFoundationLib.GlobalPositionRepresentable) -> InfoSideMenuViewModel
}

protocol PrivateSideMenuOfferDelegate: AnyObject {
    func didSelectBanner(location: PullOfferLocation)
    func executeOffer(action: OfferActionRepresentable?, offerId: String?, location: PullOfferLocationRepresentable?)
}

final class PrivateSideMenuPresenter: PrivatePresenter<PrivateSideMenuViewController, PrivateHomeNavigator & PrivateHomeNavigatorSideMenu & PublicNavigatable & BaseWebViewNavigatable & PullOffersActionsNavigatorProtocol, PrivateSideMenuPresenterProtocol> {
    
    var errorHandler: GenericPresenterErrorHandler { return genericErrorHandler }
    private var hasManager: Bool?
    private var enableSidebarManagerNotifications = false
    private var managerWallEnabled: Bool?
    private var salesforceManagerWall: Bool?
    private var userName: String?
    private var managerName: String?
    private let localAuthentication: LocalAuthenticationPermissionsManagerProtocol
    private var subscriptions: Set<AnyCancellable> = []
    
    var locationTutorial: PullOfferLocation? {
        return .MENU_MIGESTOR
    }
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().privateSideMenu
    }
    
    var personalAreaTitle: LocalizedStylableText {
        return stringLoader.getString("menu_label_personalArea")
    }
    
    var digitalProfileTitle: LocalizedStylableText {
        return stringLoader.getString("menu_label_digitalProfile")
    }
    
    var hideDigitalProfile: Bool {
        return !self.localAppConfig.isEnabledDigitalProfileView
    }
    
    override var shouldRegisterAsDeeplinkHandler: Bool {
        return false
    }
    
    private var presenterOffers: [PullOfferLocation: Offer] = [:] {
        didSet {
            view.reloadOptions()
        }
    }
    private var presenterTutorialOffers: [PullOfferLocation: Offer] = [:]
    
    private var privateMenuWrapper: PrivateMenuWrapper? {
        didSet {
            view.reloadOptions()
        }
    }
    private var options: [PrivateMenuOptions] {
        
        let allOptions: [PrivateMenuOptions] = [.globalPosition,
                                                .world123,
                                                .santanderOne1,
                                                .myProducts,
                                                .sofiaInvestments,
                                                .financing,
                                                .transfers,
                                                .bills,
                                                .topUps,
                                                .analysisArea,
                                                .contract,
                                                .marketplace,
                                                .myHome,
                                                .santanderOne2,
                                                .otherServices
        ]
        return allOptions.filter({ isIncluded($0) })
        
    }
    
    private var localAppConfig: LocalAppConfig {
        self.dependencies.localAppConfig
    }
    
    private var notificationPermissionsManager: PushNotificationPermissionsManagerProtocol? {
        self.dependencies.useCaseProvider.dependenciesResolver.resolve(forOptionalType: PushNotificationPermissionsManagerProtocol.self)
    }
    
    private lazy var otpPushManager: OtpPushManagerProtocol? = {
        self.dependencies.useCaseProvider.dependenciesResolver.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)?.getOtpPushManager()
    }()
    
    private lazy var coachmarkConditions = DispatchGroup()
    
    init(dependencies: PresentationComponent,
         navigator: PrivateHomeNavigator & PrivateHomeNavigatorSideMenu & PublicNavigatable & ModalViewsObserverProtocol & BaseWebViewNavigatable & PullOffersActionsNavigatorProtocol,
         sessionManager: CoreSessionManager,
         localAuthentication: LocalAuthenticationPermissionsManagerProtocol) {
        self.localAuthentication = localAuthentication
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var letPerformIntent: Bool {
        return false
    }
    
    override func loadViewData() {
        super.loadViewData()
        setPrivateMenu()
        addedNotifications()
        getManagersWallState()
        getPersonalManagers()
    }
    
    private func getPersonalManagers() {
        UseCaseWrapper(with: dependencies.useCaseProvider.getGetPersonalManagersUseCase(),
                       useCaseHandler: dependencies.useCaseHandler,
                       errorHandler: genericErrorHandler,
                       onSuccess: { [weak self] (result) in
            let hasAny = !result.managerList.managers.isEmpty
            self?.hasManager = hasAny
            self?.managerName = result.managerList.managers.first?.nameGest
            guard let options = self?.bottomOptions(hasManager: hasAny) else { return }
            self?.view.setBottomOptions(options)
        })
    }
    
    private func getManagersWallState() {
        UseCaseWrapper(with: dependencies.useCaseProvider.getLoadPersonalWithManagerUseCase(),
                       useCaseHandler: dependencies.useCaseHandler,
                       errorHandler: genericErrorHandler,
                       onSuccess: { [weak self] response in
            self?.managerWallEnabled = response.managerWallEnabled
            self?.salesforceManagerWall = response.managerWallVersion == 2
            self?.enableSidebarManagerNotifications = response.enableManagerNotifications
        },
                       onError: nil)
    }
    
    private func isIncluded(_ option: PrivateMenuOptions) -> Bool {
        switch option {
        case .analysisArea:
            return privateMenuWrapper?.isAnalysisMenuVisible() ?? false
        case .myProducts:
            return privateMenuWrapper?.isMyProductsAllowed() ?? false
        case .transfers:
            return privateMenuWrapper?.isTransferMenuVisible() ?? false
        case .marketplace:
            return privateMenuWrapper?.isMarketPlaceMenuVisible() ?? false
        case .bills:
            return privateMenuWrapper?.isVisibleAccountsEmpty() == false && privateMenuWrapper?.isEnabledBillsAndTaxes() == true
        case .sofiaInvestments:
            return isSofiaInvestment() || privateMenuWrapper?.isInvestmentMenuVisible() ?? false
        case .santanderOne1:
            return presenterOffers[.SIDE_MENU_ONE1] != nil
        case .santanderOne2:
            return presenterOffers[.SIDE_MENU_ONE2] != nil
        case .contract:
            return (privateMenuWrapper?.isSanflixEnabled() == true && presenterOffers[.MENU_CONTRATAR_SANFLIX] != nil)
            || privateMenuWrapper?.isEnablePublicProducts() == true
        case .myHome:
            return presenterOffers[.MY_HOME_MENU] != nil
        case .otherServices:
            return self.privateMenuWrapper?.isComingFeaturesEnabled() ?? false || presenterOffers[.HUELLA_CARBONO] != nil || privateMenuWrapper?.isSmartServicesEnabled() ?? false
        case .financing:
            return self.privateMenuWrapper?.isFinancingZoneEnabled() ?? false
        case .world123:
            return isWorld123()
        case .topUps:
            return privateMenuWrapper?.isVisibleAccountsEmpty() == false && localAppConfig.isEnabledTopUpsPrivateMenu
        default:
            return true
        }
    }
    
    private func getLocations() {
        getCandidateOffers { [weak self] candidates in
            self?.presenterOffers = candidates
        }
    }
    
    private func getTutorialLocations() {
        // It is used to display coachmarks one time per session when a location is valid
        coachmarkConditions.enter()
        getCandidateTutorialsOffers { [weak self] candidates in
            self?.presenterTutorialOffers = candidates
            self?.coachmarkConditions.leave()
        }
    }
    
    private func isSofiaInvestment() -> Bool {
        let locations = presenterOffers.map { $0.0 }
        let sofiaInvestment = PullOffersLocationsFactory().sofiaInvestment
        return sofiaInvestment.contains(where: { locations.contains($0) })
    }
    
    private func isWorld123() -> Bool {
        let locations = presenterOffers.map { $0.0 }
        let world123 = PullOffersLocationsFactory().world123SideMenu
        return world123.contains(where: { locations.contains($0) }) && localAppConfig.isEnabledWorld123
    }
    
    private func configureAvatar() {
        UseCaseWrapper(with: dependencies.useCaseProvider.getPersistedUserAvatarUseCase(),
                       useCaseHandler: dependencies.useCaseHandler,
                       errorHandler: genericErrorHandler,
                       onSuccess: { [weak self] (result) in
            guard let image = result.image else { return }
            self?.view.setAvatarImage(image)
        })
    }
    
    func getHighlightView() -> PrivateMenuOptions? {
        guard let view = self.navigator.highlight
        else {
            return nil
        }
        return view.getOption()
    }
}

// MARK: - PrivateSideMenuPresenterProtocol

extension PrivateSideMenuPresenter: PrivateSideMenuPresenterProtocol, ManagerImageURLFetcher, PrivateSideMenuFooterProtocol {
    
    var actionNavigator: PrivateHomeNavigator & PrivateHomeNavigatorSideMenu {
        return navigator
    }
    
    func didTapCloseCoachmark() {
        view.hideCoachmark()
    }
    
    func didTapHelpUs() {
        navigator.closeSideMenu()
        if localAppConfig.isEnabledHelpUsInMenu == true {
            openOpinator()
        } else {
            showNotAvailableToast()
        }
    }
    
    func didTapPersonalArea() {
        navigator.closeSideMenu()
        if localAppConfig.isEnabledPersonalAreaInMenu == true {
            navigator.goToPersonalArea()
        } else {
            showNotAvailableToast()
        }
    }
    
    func didTapDigitalProfile() {
        navigator.closeSideMenu()
        navigator.goToPersonalArea()
    }
    
    func topOption() -> PrivateMenuOption {
        return MenuOptionData(title: stringLoader.getString("menu_link_exit"),
                              iconKey: "icnExit",
                              accessibilityIdentifier: AccessibilitySideMenu.btnExit) { [weak self] in
            self?.performExit()
            self?.dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.LogoutConfirm().page,
                                                          extraParameters: [:])
        }
    }
    
    func coachmarkDisplayed() {
        UseCaseWrapper(with: dependencies.useCaseProvider.setCoachmarkSeen(input: SetCoachmarkSeenInput(coachmarkIds: [.sideMenuManager])),
                       useCaseHandler: dependencies.useCaseHandler,
                       errorHandler: genericErrorHandler)
    }
    
    func didShowSideMenu(_ isVisible: Bool) {
        guard isVisible == true else {
            view.resetProgress()
            view.resetTableViewOptions()
            return
        }
        self.trackScreen()
        view.reloadOptions()
        DispatchQueue.main.async {
            self.view.animateTableViewOptions()
        }
        self.otpPushManager?.updateToken(completion: { [weak self] _, _ in
            guard let self = self else { return }
            let input = GetDigitalProfilePercentageUseCaseInput(pushNotificationsManager: self.notificationPermissionsManager,
                                                                locationManager: self.dependencies.locationManager,
                                                                localAuthentication: self.localAuthentication)
            let usecase = self.dependencies.useCaseProvider.getDigitalProfilePercentageUseCase(input: input)
            UseCaseWrapper(with: usecase,
                           useCaseHandler: self.dependencies.useCaseHandler,
                           errorHandler: self.genericErrorHandler,
                           onSuccess: { [weak self] result in
                self?.view.setDigitalProfileProgress(value: Float(result.percentage/100), text: "\(Int(result.percentage))%")
                self?.trackDigitalProfileItems(notConfigured: result.notConfiguredItems, percentage: result.percentage)
            })
        })
        
        guard hasManager == true else { return }
        
        getTutorialLocations()
        getManagerNotifications()
        
        UseCaseWrapper(with: dependencies.useCaseProvider.getManagerCoachmarkData(input: DisplaySideMenuManagerUseCaseInput(coachmarkId: .sideMenuManager)),
                       useCaseHandler: dependencies.useCaseHandler,
                       onSuccess: { [weak self] (response) in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                self.coachmarkConditions.wait() // Waits for candidates locations before continue
                let isOfferAvailable: Bool = self.presenterTutorialOffers[.MENU_MIGESTOR] != nil
                let numberOfBanners = self.presenterTutorialOffers[.MENU_MIGESTOR]?.banners.count ?? 0
                guard
                    response.isCoachmarkManagerEnabled == true,
                    (response.wasDisplayedBefore == false || numberOfBanners >= 1)
                else { return }
                
                Async.main { [weak self] in
                    guard let self = self else { return }
                    let managerCoachInfo = ManagerCoachmarkInfo(title: self.coachmarkTitle, subtitle: self.coachmarkSubtitle)
                    if isOfferAvailable,
                       let offer = self.presenterTutorialOffers[.MENU_MIGESTOR],
                       let offerURL = offer.banners.first(where: {$0.app?.lowercased().contains("ios") ?? false})?.url {
                        managerCoachInfo.setOfferWithBanner(subtitle: offer.description, bannerString: offerURL) { [weak self] in
                            self?.view.hideCoachmark()
                            self?.navigator.closeSideMenu()
                            self?.executeOffer(action: offer.action, offerId: offer.id, location: PullOfferLocation.MENU_MIGESTOR)
                        }
                    }
                    self.requestManagerImageURL(using: self.dependencies) { (stringURL) in
                        managerCoachInfo.imageURL = stringURL
                    }
                    self.view.displayCoachmarkIfNeeded(managerCoachInfo)
                }
            }
        })
    }
    
    func reloadNameHeader() {
        self.setNameHeader()
    }
    
    private func trackDigitalProfileItems(notConfigured: [DigitalProfileElemProtocol], percentage: Double) {
        notConfigured.forEach { item in
            self.trackDigitalProfileEvent(item.trackName())
        }
        self.trackDigitalProfileEvent("\(Int(percentage))")
    }
    
    private func trackDigitalProfileEvent(_ event: String) {
        self.trackEvent(.digitalProfile, parameters: [.digitalProfileNotConfigured: event])
    }
    
    private var coachmarkTitle: LocalizedStylableText {
        let now = Date()
        let hour = Calendar.current.component(.hour, from: now)
        
        switch hour {
        case 5...13:
            return stringLoader.getString("menu_text_managerGoodMorning", [StringPlaceholder(.name, userName?.camelCasedString ?? "")])
        case 14...19:
            return stringLoader.getString("menu_text_managerGoodAfternoon", [StringPlaceholder(.name, userName?.camelCasedString ?? "")])
        default:
            return stringLoader.getString("menu_text_managerGoodEvening", [StringPlaceholder(.name, userName?.camelCasedString ?? "")])
        }
    }
    
    private var coachmarkSubtitle: LocalizedStylableText {
        return stringLoader.getString("menu_text_myManager", [StringPlaceholder(.name, managerName?.capitalized ?? "")])
    }
    
    private func getManagerNotifications() {
        guard enableSidebarManagerNotifications == true, managerWallEnabled == true, salesforceManagerWall == true else { return }
        UseCaseWrapper(with: self.dependencies.useCaseProvider.getManagerNotificationsUseCase(),
                       useCaseHandler: self.dependencies.useCaseHandler,
                       onSuccess: { [weak self] result in
            self?.view.setNotificationBadgeVisible(result.hasNewNotifications,
                                                   inCoachmark: .sideMenuManager)
        })
    }
}

// MARK: - Notifications

extension PrivateSideMenuPresenter {
    private func addedNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeAvatarImage), name: .didChangeAvatarImage, object: nil)
    }
    
    @objc private func didChangeAvatarImage() {
        configureAvatar()
    }
}

extension PrivateSideMenuPresenter: LocationsResolver {}

extension PrivateSideMenuPresenter: PullOfferActionsPresenter {
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
    
    var presentationView: ViewControllerProxy {
        return navigator.drawer
    }
}

extension PrivateSideMenuPresenter {
    
    private func performExit() {
        navigator.closeSideMenu()
        navigator.showLogoutDialog(
            acceptAction: { [weak self] in
                self?.updateCurrentRootViewWillAppearAction(nil)
                self?.sessionManager.finishWithReason(.logOut)
                self?.dependencies.trackerManager.trackEvent(screenId: TrackerPagePrivate.LogoutConfirm().page, eventId: TrackerPagePrivate.LogoutConfirm.Action.ok.rawValue, extraParameters: [:])
            },
            offerDidOpenAction: { [weak self] in
                // In order to open the logout dialog again once the user go back to the current view (but we have to hide the offer)
                self?.updateCurrentRootViewWillAppearAction { [weak self] in
                    self?.performExit()
                }
            }
        )
    }
    
    private func updateCurrentRootViewWillAppearAction(_ willAppearAction: (() -> Void)?) {
        var willAppearActionable = navigator.drawerRoot(as: WillAppearActionable.self)
        willAppearActionable?.willAppearAction = willAppearAction
    }
    
    func textForBarOption(number: Int) -> LocalizedStylableText? {
        guard let option = PrivateBarMenuOption.title(for: number) else {
            return nil
        }
        return stringLoader.getString(option)
    }
    
    func menuItems() -> [MenuItemViewModelSection] {
        var result = [MenuItemViewModelSection]()
        let newMessage: LocalizedStylableText = stringLoader.getString("menu_label_newProminent")
        let highlightedSection = getHighlightView()
        for option in options {
            let section = MenuItemViewModelSection()
            let title = stringLoader.getString(option.titleKey)
            let isHighlighted = highlightedSection == option
            let featuredOptionMessage = privateMenuWrapper?.featuredOptions[option]
            let isFeaturedEmpty = featuredOptionMessage == nil
            
            let item = SideMenuFeaturedItemTableViewModel(
                title: title,
                imageKey: option.iconKey,
                extraMessage: featuredOptionMessage ?? "",
                newMessage: isFeaturedEmpty ? nil: newMessage,
                viewModelPrivateComponent: dependencies,
                showArrow: option.submenuArrow,
                isHighlighted: isHighlighted,
                type: option,
                isFeatured: !isFeaturedEmpty
            )
            section.add(item: item)
            section.isFeatured = !isFeaturedEmpty
            item.didSelect = actionForListOption(option)
            item.accessibilityIdentifier = option.accessibilityIdentifier
            
            result.append(section)
        }
        return result
    }
    
    func selectSection(_ section: TableModelViewSection) {
        let option = section.items.first as? Executable
        option?.execute()
    }
    
    // MARK: - Helpers
    
    private func actionForListOption(_ option: PrivateMenuOptions) -> () -> Void {
        switch option {
        case .myProducts:
            return { [weak self] in
                guard let strongSelf = self, let privateMenuWrapper = strongSelf.privateMenuWrapper else { return }
                self?.navigator.goToMyProducts(privateMenuWrapper: privateMenuWrapper, offerDelegate: strongSelf)
            }
        case .sofiaInvestments:
            return { [weak self] in
                guard let strongSelf = self, let privateMenuWrapper = strongSelf.privateMenuWrapper else { return }
                self?.navigator.goToSofiaInvestment(privateMenuWrapper: privateMenuWrapper, offerDelegate: strongSelf)
            }
        case .contract:
            return { [weak self] in
                guard let self = self else { return }
                self.navigator.closeSideMenu()
                if self.privateMenuWrapper?.isEnabledExploreProducts() == true {
                    self.navigator.setOnlyFirstViewControllerToGP()
                    self.goToPublicProducts(delegate: self, location: PullOfferLocation.MENU_CONTRATAR_SANFLIX)
                } else {
                    self.showNotAvailableToast()
                }
            }
        case .analysisArea:
            return { [weak self] in
                self?.navigator.closeSideMenu()
                if self?.localAppConfig.isEnabledAnalysisArea == true {
                    self?.navigator.goToAnalysisArea()
                    self?.navigator.setFirstViewControllerToGP()
                } else {
                    self?.showNotAvailableToast()
                }}
        case .santanderOne1:
            return { [weak self] in
                self?.navigator.closeSideMenu()
                self?.didSelectBanner(location: .SIDE_MENU_ONE1)
            }
        case .santanderOne2:
            return { [weak self] in
                self?.navigator.closeSideMenu()
                self?.didSelectBanner(location: .SIDE_MENU_ONE2)
            }
        case .globalPosition:
            return { [weak self] in
                self?.navigator.backToGlobalPosition()
                self?.navigator.closeSideMenu()
            }
        case .marketplace:
            return { [weak self] in
                self?.navigator.closeSideMenu()
                self?.openMarketplace()
            }
        case .transfers:
            return { [weak self] in
                self?.navigator.closeSideMenu()
                if self?.localAppConfig.isEnabledSendMoney == true {
                    self?.navigateToTransfers()
                } else {
                    self?.showNotAvailableToast()
                }}
        case .bills:
            return { [weak self] in
                self?.navigator.closeSideMenu()
                if self?.localAppConfig.isEnabledBills == true {
                    self?.navigateToBillAndTax()
                } else {
                    self?.showNotAvailableToast()
                }}
        case .financing:
            return { [weak self] in
                self?.navigator.closeSideMenu()
                self?.navigateToFinance()
            }
        case .myHome:
            return { [weak self] in
                self?.navigator.closeSideMenu()
                self?.didSelectBanner(location: .MY_HOME_MENU)
            }
        case .otherServices:
            return { [weak self] in
                guard let strongSelf = self, let privateMenuWrapper = strongSelf.privateMenuWrapper else { return }
                self?.navigator.goToOtherServices(privateMenuWrapper: privateMenuWrapper,
                                                  offerDelegate: strongSelf,
                                                  comingFeatures: privateMenuWrapper.isComingFeaturesEnabled())
            }
        case .world123:
            return { [weak self] in
                guard let strongSelf = self, let privateMenuWrapper = strongSelf.privateMenuWrapper else { return }
                self?.navigator.goToWorld123(privateMenuWrapper: privateMenuWrapper,
                                             offerDelegate: strongSelf,
                                             comingFeatures: privateMenuWrapper.isComingFeaturesEnabled())
            }
        case .topUps:
            return { [weak self] in
                self?.navigator.closeSideMenu()
                self?.navigateToTopUp()
            }
        default:
            return { [weak self] in
                self?.navigator.closeSideMenu()
            }
        }
    }
}

private extension PrivateSideMenuPresenter {
    
    // MARK: - Internal classes
    func setPrivateMenu() {
        getPrivateMenuOptions()
        self.getLocations()
        self.configureAvatar()
    }
    
    func getPrivateMenuOptions() {
        MainThreadUseCaseWrapper(
            with: useCaseProvider.getPrivateMenuDataUseCase(),
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] (result) in
                self?.privateMenuWrapper = result.privateMenuWrapper
            },
            onError: { [weak self] (_) in
                self?.privateMenuWrapper = nil
            })
    }
    
    func setNameHeader() {
        self.getUserInfo { infoSideMenu in
            guard let avaliableName = infoSideMenu.availableName else { return }
            self.userName = avaliableName
            self.view.setUserName(avaliableName)
            self.setInitials(infoSideMenu.initials)
        }
    }
    
    func setInitials(_ initials: String?) {
        if let initials = initials {
            view.setUserInitials(initials)
        }
    }
    
    func getUserInfo(_ completion: @escaping (InfoSideMenuViewModel) -> Void) {
        guard let privateMenuWrapper = self.privateMenuWrapper else { return }
        
        if let modifier = dependencies.useCaseProvider.dependenciesResolver.resolve(forOptionalType: PrivateSideMenuModifier.self) {
            let viewModel = modifier.getConfiguration(globalPosition: privateMenuWrapper.globalPositionPreferences.globalPosition)
            completion(viewModel)
        } else {
            let useCase = self.dependencies.useCaseProvider.dependenciesResolver.resolve(for: GetInfoSideMenuUseCaseProtocol.self)
            let input = GetInfoSideMenuUseCaseInput(globalPosition: privateMenuWrapper)
            Scenario(useCase: useCase, input: input)
                .execute(on: self.dependencies.useCaseHandler)
                .onSuccess { result in
                    let viewModel = InfoSideMenuViewModel(availableName: result.infoSideMenuEntity.availableName, initials: result.infoSideMenuEntity.initials)
                    completion(viewModel)
                }
        }
    }
    
    func openOpinator() {
        dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.HelpImprove().page, extraParameters: [:])
        openOpinator(forRegularPage: .general, onError: { [weak self] errorDescription in
            self?.showError(keyDesc: errorDescription)
        })
    }
    
    func openTransfers() {
        openOpinator(forRegularPage: .general, onError: { [weak self] errorDescription in
            self?.showError(keyDesc: errorDescription)
        })
    }
    
    func openMarketplace() {
        dependencies.locationManager.getCurrentLocation { [weak self] latitude, longitude in
            guard let strongSelf = self else { return }
            UseCaseWrapper(with: strongSelf.useCaseProvider.getMarketplaceUseCase(input: GetMarketplaceWebViewConfigurationInput(latitude: latitude, longitude: longitude)), useCaseHandler: strongSelf.useCaseHandler, errorHandler: strongSelf.genericErrorHandler, onSuccess: { (result) in
                guard let presenter = self else {
                    return
                }
                presenter.navigator.goToWebView(with: result.configuration, linkHandlerType: .marketplace, dependencies: presenter.dependencies, errorHandler: presenter.genericErrorHandler, didCloseClosure: nil)
                self?.navigator.setFirstViewControllerToGP()
            })
        }
    }
    
    func transferHomeFeatureFlag() {
        let booleanFeatureFlag: BooleanFeatureFlag = self.dependencies.useCaseProvider.dependenciesResolver.resolve()
        booleanFeatureFlag.fetch(CoreFeatureFlag.transferHome)
            .filter { $0 == true }
            .sink { [unowned self] _ in
                self.dependencies.navigatorProvider.legacyExternalDependenciesResolver.oneTransferHomeCoordinator().start()
            }.store(in: &subscriptions)
        booleanFeatureFlag.fetch(CoreFeatureFlag.transferHome)
            .filter { $0 == false }
            .sink { [unowned self] _ in
                self.navigator.goToTransfers(section: .home)
            }.store(in: &subscriptions)
    }
    
    func navigateToTransfers() {
        guard let transfersHomeOption = self.dependencies.useCaseProvider.dependenciesResolver.resolve(forOptionalType: PrivateMenuTransferOptionProtocol.self) else {
            transferHomeFeatureFlag()
            return
        }
        transfersHomeOption.goToTransfersHome()
    }
    
    func navigateToBillAndTax() {
        if let privateMenuModifier = privateMenuProtocol {
            privateMenuModifier.goToPaymentsLandingPage()
        } else {
            self.navigator.goToBillsAndTaxes()
        }
        self.navigator.setFirstViewControllerToGP()
    }
    
    func navigateToTopUp() {
        guard let privateMenuModifier = privateMenuProtocol else { return }
        privateMenuModifier.goToTopUpLandingPage()
        self.navigator.setFirstViewControllerToGP()
    }
    
    func navigateToFinance() {
        if let privateMenuModifier = privateMenuProtocol {
            privateMenuModifier.goToFinanceLandingPage()
        } else {
            self.navigator.goToFinancing()
        }
        self.navigator.setFirstViewControllerToGP()
    }
}

extension PrivateSideMenuPresenter: SantanderAppsLauncher {
    var santanderAppsNavigator: BaseWebViewNavigatable {
        return navigator
    }
}

extension PrivateSideMenuPresenter: OpinatorLauncher {
    var baseWebViewNavigatable: BaseWebViewNavigatable {
        return navigator
    }
}

extension Notification.Name {
    static let didLoadGlobalPositionWrapper: Notification.Name = Notification.Name(rawValue: "didLoadGlobalPositionWrapper")
}

extension PrivateSideMenuPresenter: VirtualAssistantLauncher {
    var virtualAssistantNavigator: BaseWebViewNavigatable {
        return navigator
    }
}

extension PrivateSideMenuPresenter: PublicProductsLauncher, PublicProductsLauncherDelegate {
    var offerPresenter: PullOfferActionsPresenter { self }
}

extension PrivateSideMenuPresenter: PrivateSideMenuOfferDelegate {
    func didSelectBanner(location: PullOfferLocation) {
        guard let offer = presenterOffers[location],
              let offerAction = offer.action
        else { return }
        executeOffer(action: offerAction, offerId: offer.id, location: location)
    }
}

extension PrivateSideMenuPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return self.dependencies.trackerManager
    }
    
    var trackerPage: PrivateMenuPage {
        return PrivateMenuPage()
    }
}

extension PrivateSideMenuPresenter {
    var privateMenuProtocol: PrivateMenuProtocol? {
        return self.dependencies.useCaseProvider.dependenciesResolver.resolve(forOptionalType: PrivateMenuProtocol.self)
    }
    
    var transfersHomeOption: PrivateMenuTransferOptionProtocol? {
        return self.dependencies.useCaseProvider.dependenciesResolver.resolve(forOptionalType: PrivateMenuTransferOptionProtocol.self)
    }
}
