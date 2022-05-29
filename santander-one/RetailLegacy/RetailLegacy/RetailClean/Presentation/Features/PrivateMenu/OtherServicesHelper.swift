import CoreFoundationLib
import CoreDomain

final class OtherServicesOption: PrivateSubmenuOptionRepresentable {
    
    private let isPb: Bool
    let type: PrivateMenuOtherServicesOptionType
    
    var titleKey: String {
        switch type {
        case .next:
            return "menu_link_shortly"
        case .carbonFingerPrint:
            return "menu_link_fingerPrint"
        case .smartServices:
            return "menu_link_smart"
        }
    }
    
    var icon: String? {
        switch type {
        case .next:
            return "icnShortlyMenu"
        case .carbonFingerPrint:
            return "icnCo2"
        case .smartServices:
            return "icnServicesMenu"
        }
    }
    
    public var submenuArrow: Bool {
        self.type == .smartServices
    }
    
    init(isPb: Bool, type: PrivateMenuOtherServicesOptionType) {
        self.isPb = isPb
        self.type = type
    }
}

extension OtherServicesOption: AccessibilityProtocol {
    var accessibilityIdentifier: String? {
        switch type {
        case .smartServices:
            return AccessibilitySideMenu.btnSmart.rawValue
        case .next:
            return AccessibilitySideMenu.btnShortly.rawValue
        case .carbonFingerPrint:
            return AccessibilitySideMenu.btnCarbonFingerPrint.rawValue
        }
    }
}

final class OtherServicesHelper {
    private var completion: (([PrivateSubmenuOptionRepresentable]) -> Void)?
    private weak var presenter: PrivateSubmenuPresenter?
    private var navigator: PrivateHomeNavigator & PrivateHomeNavigatorSideMenu
    private weak var offerDelegate: PrivateSideMenuOfferDelegate?
    private var comingFeatures: Bool
    
    var privateMenuWrapper: PrivateMenuWrapper
    
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().otherServicesSideMenu
    }
        
    init(privateMenuWrapper: PrivateMenuWrapper,
         presenter: PrivateSubmenuPresenter,
         navigator: PrivateHomeNavigator & PrivateHomeNavigatorSideMenu,
         offerDelegate: PrivateSideMenuOfferDelegate,
         comingFeatures: Bool) {
        self.privateMenuWrapper = privateMenuWrapper
        self.presenter = presenter
        self.navigator = navigator
        self.offerDelegate = offerDelegate
        self.comingFeatures = comingFeatures
    }
    
    private func wrapperUpdated() {
        var options: [OtherServicesOption] = []
        getCandidateOffers { [weak self] candidates in
            guard let self = self else { return }
            let isPb = self.privateMenuWrapper.isPb
            if self.comingFeatures {
                options += [OtherServicesOption(isPb: isPb, type: .next)]
            }
            if candidates[.HUELLA_CARBONO] != nil {
                options += [OtherServicesOption(isPb: isPb, type: .carbonFingerPrint)]
            }
            if self.privateMenuWrapper.isSmartServicesEnabled() {
                options += [OtherServicesOption(isPb: isPb, type: .smartServices)]
            }
            self.completion?(options)
        }
    }
}

extension OtherServicesHelper: PrivateMenuSectionHelper {
    var titleKey: String {
        return "menu_link_otherServices"
    }
    var sidebarProductsTitle: String? { nil }
    var hasTitle: Bool { false }
    func getOptionsList(completion: @escaping (([PrivateSubmenuOptionRepresentable]) -> Void)) {
        self.completion = completion
        wrapperUpdated()
    }
    
    func titleForOption(_ option: PrivateSubmenuOptionRepresentable) -> String {
        guard let option = option as? OtherServicesOption else { return "" }
        return localized(option.titleKey)
    }

    func selected(option: PrivateSubmenuOptionRepresentable) {
        guard let option = option as? OtherServicesOption else {
            return
        }
        switch option.type {
        case .next:
            navigator.closeSideMenu()
            navigator.goToComingSoon()
            navigator.setFirstViewControllerToGP()
        case .smartServices:
            navigator.goToServicesForYouHelper(offerDelegate: self)
        case .carbonFingerPrint:
            navigator.closeSideMenu()
            offerDelegate?.didSelectBanner(location: .HUELLA_CARBONO)
            navigator.setFirstViewControllerToGP()
        }
    }
}

extension OtherServicesHelper: PrivateSideMenuOfferDelegate {
    func didSelectBanner(location: PullOfferLocation) {
        offerDelegate?.didSelectBanner(location: location)
    }
    
    func executeOffer(action: OfferActionRepresentable?, offerId: String?, location: PullOfferLocationRepresentable?) {
        offerDelegate?.executeOffer(action: action, offerId: offerId, location: location)
    }    
}

extension OtherServicesHelper: LocationsResolver {
    var useCaseProvider: UseCaseProvider {
        guard let presenter = presenter else { fatalError() }
        return presenter.useCaseProvider
    }
    
    var useCaseHandler: UseCaseHandler {
        guard let presenter = presenter else { fatalError() }
        return presenter.useCaseHandler
    }
    
    var genericErrorHandler: GenericPresenterErrorHandler {
        guard let presenter = presenter else { fatalError() }
        return presenter.genericErrorHandler
    }
}
