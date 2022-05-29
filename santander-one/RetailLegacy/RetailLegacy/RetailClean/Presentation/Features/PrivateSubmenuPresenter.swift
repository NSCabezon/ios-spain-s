import CoreFoundationLib
import CoreDomain

final class PrivateSubmenuPresenter: PrivatePresenter<PrivateSubmenuViewController, PrivateHomeNavigator & PrivateHomeNavigatorSideMenu & BaseWebViewNavigatable & PullOffersActionsNavigatorProtocol, PrivateSubmenuPresenterProtocol> {
    var helper: PrivateSubmenuOptionHelperRepresentable?
    var insuranceDetailEnabled = false
    private var enableSidebarManagerNotifications: Bool = false
    private var managerWallEnabled: Bool?
    private var salesforceManagerWall: Bool?
    private var presenterOffers: [PullOfferLocation: Offer] = [:]
    private var myProductMenuWrapper: MyProductMenuWrapper?
    
    var locations: [PullOfferLocation] {
        let productLocations = PullOffersLocationsFactoryEntity().myProducts
        let investmentLocations = PullOffersLocationsFactoryEntity().investmentSubmenuOffers
        return productLocations + investmentLocations
    }
    
    var myProductsOptions: [PrivateSubMenuOptions] {
        return [
            .sidebarStock,
            .sidebarPensions,
            .sidebarFunds,
            .sidebarInsurance,
            .sidebarDeposits
        ]
    }
    
    var sofiaInvestmentsOptions: [PrivateSubMenuOptions] {
        return [
            .sidemenuInvestSubsection1,
            .sidemenuInvestSubsection2,
            .sidemenuInvestSubsection3,
            .sidemenuInvestSubsection4,
            .sidemenuInvestSubsection5,
            .sidemenuInvestSubsection6,
            .sidemenuInvestSubsection7,
            .sidemenuInvestSubsection8,
            .menuInvestmentDeposit
        ]
    }
    
    private var localAppConfig: LocalAppConfig {
        self.dependencies.localAppConfig
    }
    
    override func loadViewData() {
        self.getLocations { [weak self] in
            guard let self = self else { return }
            guard let helper = self.helper else { return }
            self.view.sectionTitle = self.stringLoader.getString(helper.titleKey)
            self.view.sectionSuperTitle = self.localized(key: helper.superTitleKey ?? "")
            helper.getOptionsList(completion: { [weak self] list in
                guard let self = self else { return }
                self.view.addSections(sections: self.menuItems(from: list))
                if helper is MyProductsHelper {
                    self.view.addSections(sections: self.offerItems(from: self.myProductsOptions))
                } else {
                    self.view.addSections(sections: self.offerItems(from: self.sofiaInvestmentsOptions))
                }
            })
            self.getInsuranceDetailEnabled()
            UseCaseWrapper(
                with: self.dependencies.useCaseProvider.getHasAnyManagerUseCase(),
                useCaseHandler: self.dependencies.useCaseHandler,
                errorHandler: self.genericErrorHandler,
                onSuccess: { [weak self] (result) in
                    if let options = self?.bottomOptions(hasManager: result.hasAny) {
                        self?.view.setBottomOptions(options)
                    }
                    if result.hasAny {
                        self?.getManagerInfo()
                    }
            })
        }
    }
    
    func presentInsurancesMessage() {
        self.navigator.popToFirstLevel()
        guard let root = navigator.drawerRoot else { return }
        let accept = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept"), does: nil)
        Dialog.alert(
            title: nil,
            body: stringLoader.getString("insurancesDetail_label_error"),
            withAcceptComponent: accept,
            withCancelComponent: nil,
            source: root
        )
    }
}

private extension PrivateSubmenuPresenter {
    func getManagerInfo() {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getLoadPersonalWithManagerUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] response in
                self?.managerWallEnabled = response.managerWallEnabled
                self?.salesforceManagerWall = response.managerWallVersion == 2
                self?.enableSidebarManagerNotifications = response.enableManagerNotifications
                self?.getManagerNotifications()
            },
            onError: nil
        )
    }
    func openOpinator() {
        dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.HelpImprove().page, extraParameters: [:])
        openOpinator(forRegularPage: .general, onError: { [weak self] errorDescription in
            self?.showError(keyDesc: errorDescription)
        })
    }
    
    func getLocations(completion: @escaping () -> Void) {
        self.getCandidateOffers { [weak self] candidates in
            self?.presenterOffers = candidates
            completion()
        }
    }
    
    func addTitleSection() {
        let titleSection = MenuItemViewModelSection()
        let itemTitleSection = SideMenuTitleSectionViewModel(
            title: helper?.sidebarProductsTitle?.uppercased() ?? "",
            viewModelPrivateComponent: dependencies,
            accesibilityID: AccessibilitySideInteresting.sectionInterestingLabel
        )
        titleSection.add(item: itemTitleSection)
        self.view.addSections(sections: [titleSection])
    }
    
    func menuItems(from list: [PrivateSubmenuOptionRepresentable]) -> [MenuItemViewModelSection] {
        return list.map { createViewModel(from: $0, with: self.dependencies) }
    }
    
    func offerItems(from list: [PrivateSubMenuOptions]) -> [MenuItemViewModelSection] {
        guard
            self.helper?.hasTitle == true,
            hasLocationsEnabled(options: list)
        else {
            return []
        }
        self.addTitleSection()
        return list.compactMap { self.createViewModelOffers(from: $0, with: self.dependencies) }
    }
    
    func hasLocationsEnabled(options: [PrivateSubMenuOptions]) -> Bool {
        return options.contains(where: { self.presenterOffers.contains(location: $0.location) })
    }
    
    func createViewModel(from option: PrivateSubmenuOptionRepresentable, with dependencies: PresentationComponent) -> MenuItemViewModelSection {
        let section = MenuItemViewModelSection()
        let title = self.helper?.titleForOption(option)
        let showArrow = option.submenuArrow
        var featuredOptionMessage: String?
        if let index = option as? PrivateMenuMyProductsOption {
            featuredOptionMessage = self.myProductMenuWrapper?.featuredOptions[index]
        }
        let isFeaturedEmpty = featuredOptionMessage == nil
        let newMessage: LocalizedStylableText = stringLoader.getString("menu_label_newProminent")
        let item = SideMenuFeaturedItemTableViewModel(
            title: localized(key: title ?? ""),
            imageKey: option.icon,
            imageURL: option.iconURL,
            extraMessage: featuredOptionMessage ?? "",
            newMessage: isFeaturedEmpty ? nil: newMessage,
            viewModelPrivateComponent: dependencies,
            showArrow: showArrow,
            isHighlighted: false,
            type: nil,
            isFeatured: !isFeaturedEmpty,
            isInnerTitle: option.isInnerTitle
        )
        section.add(item: item)
        item.didSelect = { [weak self] in
            self?.helper?.selected(option: option)
            if option is OtherServicesOption { return }
            self?.navigator.popToFirstLevel()
        }
        item.accessibilityIdentifier = (option as? AccessibilityProtocol)?.accessibilityIdentifier
        return section
    }

    func getInsuranceDetailEnabled() {
        UseCaseWrapper(
            with: useCaseProvider.getInsuranceDetailEnabledUseCase(),
            useCaseHandler: self.useCaseHandler,
            errorHandler: self.genericErrorHandler,
            onSuccess: { [weak self] (response) in
                guard let strongSelf = self else { return }
                strongSelf.insuranceDetailEnabled = response.insuranceDetailEnabled
            }
        )
    }
    
    func getManagerNotifications() {
        guard enableSidebarManagerNotifications == true,
            managerWallEnabled == true,
            salesforceManagerWall == true
            else { return }
        UseCaseWrapper(
            with: self.dependencies.useCaseProvider.getManagerNotificationsUseCase(),
            useCaseHandler: self.dependencies.useCaseHandler,
            onSuccess: { [weak self] result in
                self?.view.setNotificationBadgeVisible(
                    result.hasNewNotifications,
                    inCoachmark: .sideMenuManager
                )
            }
        )
    }
}

extension PrivateSubmenuPresenter: OpinatorLauncher {
    var baseWebViewNavigatable: BaseWebViewNavigatable {
        return navigator
    }
}

extension PrivateSubmenuPresenter: PrivateSubmenuPresenterProtocol {
    
    func selectSection(_ section: TableModelViewSection) {
        let option = section.items.first as? Executable
        option?.execute()
    }
    
    func backbuttonTouched() {
        navigator.goBack()
    }
}

extension PrivateSubmenuPresenter: PrivateSideMenuFooterProtocol {
    var actionNavigator: PrivateHomeNavigator & PrivateHomeNavigatorSideMenu {
        return navigator
    }
    
    func didTapHelpUs() {
        navigator.closeSideMenu()
        openOpinator()
    }
}

extension PrivateSubmenuPresenter: LocationsResolver {}

private extension PrivateSubmenuPresenter {
    func actionForListOption(_ option: PrivateSubMenuOptions) -> () -> Void {
        return { [weak self] in
            guard
                let self = self,
                let location = self.getLocation(option.location) else { return }
            self.didSelectBanner(location: location)
            self.navigator.closeSideMenu()
        }
    }
    
    func createViewModelOffers(from option: PrivateSubMenuOptions,
                               with dependencies: PresentationComponent) -> MenuItemViewModelSection? {
        guard let offer = self.getOffer(option.location) else { return nil }
        let section = MenuItemViewModelSection()
        if self.checkBanner(option.location) {
            let item = BannerMenuViewModel(
                url: offer.banners.first?.url ?? "",
                bannerOffer: offer,
                actionDelegate: self,
                dependencies: dependencies
            )
            item.didSelect = actionForListOption(option)
            item.accessibilityIdentifier = option.accessibilityId
            section.add(item: item)
            return section
        } else {
            let item = MenuOfferTableViewModel(
                title: stringLoader.getString(option.titleKey),
                imageKey: option.imageKey,
                didSelect: actionForListOption(option),
                viewModelPrivateComponent: dependencies
            )
            section.add(item: item)
            return section
        }
    }
    
    func getLocation(_ offer: String) -> PullOfferLocation? {
        return self.locations.first { $0.stringTag == offer }
    }
    
    func getOffer(_ location: String) -> Offer? {
        let offer = self.presenterOffers.filter { $0.key.stringTag == location }.first
        return offer?.value
    }
    
    func checkBanner(_ location: String) -> Bool {
        guard let offer = self.getOffer(location) else { return false }
        return offer.banners.count > 0 ? true : false
    }
}

extension PrivateSubmenuPresenter: PullOfferActionsPresenter {
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
    
    var presentationView: ViewControllerProxy {
        return navigator.drawer
    }
}

extension PrivateSubmenuPresenter: PrivateSideMenuOfferDelegate {
    func didSelectBanner(location: PullOfferLocation) {
        if let offer = presenterOffers[location] {
            guard let offerAction = offer.action else { return }
            executeOffer(action: offerAction, offerId: offer.id, location: location)
        }
    }
}

extension PrivateSubmenuPresenter: BannerMenuViewModelDelegate {
    func finishDownloadImage() {
        self.view.addSections(sections: [])
    }
}
