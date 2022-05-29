import CoreFoundationLib
import CoreDomain

struct MyServicesForYouOption: PrivateSubmenuOptionRepresentable {
    var iconURL: String?
    var titleKey: String    
    var icon: String?
    var category: CategoryRepresentable?
}

final class SmartServicesHelper {
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().myServices
    }
    
    private var servicesForYou: ServicesForYou? {
        didSet {
            updatedOptions()
        }
    }
    private var completion: (([PrivateSubmenuOptionRepresentable]) -> Void)?
    private weak var presenter: PrivateSubmenuPresenter?
    private var navigator: PrivateHomeNavigator
    private weak var offerDelegate: PrivateSideMenuOfferDelegate?
    private var candidates: [PullOfferLocation: Offer]?
    var options: [MyServicesForYouOption] = []
    
    init(presenter: PrivateSubmenuPresenter, navigator: PrivateHomeNavigator, offerDelegate: PrivateSideMenuOfferDelegate) {
        self.presenter = presenter
        self.navigator = navigator
        self.offerDelegate = offerDelegate
    }
    
    private func updatedOptions() {
        if let services4u = servicesForYou, let categories = services4u.categories {
            for category in categories {
                guard let name = category.name, let icon = category.iconRelativeURL else { return }
                options.append(MyServicesForYouOption(iconURL: icon, titleKey: name, icon: nil, category: category))
            }
        }
    }
    
    private func addLocationOption() {
        getCandidateOffers { [weak self] candidates in
            if candidates[.TRAE_UN_AMIGO] != nil {
                self?.options.append(MyServicesForYouOption(iconURL: nil, titleKey: "menu_link_friendPlan", icon: "icnFriend", category: nil))
            }
            self?.candidates = candidates
            self?.completion?(self?.options ?? [])
        }
    }
}

extension SmartServicesHelper: PrivateSubmenuOptionHelperRepresentable {
    func titleForOption(_ option: PrivateSubmenuOptionRepresentable) -> String {
         guard let option = option as? MyServicesForYouOption else { return "" }
               return localized(option.titleKey)
    }
    
    var superTitleKey: String? {
        return "menu_link_otherServices"
    }
    
    var titleKey: String {
        return "menu_link_forYou"
    }
    var sidebarProductsTitle: String? { nil }
    var hasTitle: Bool { false }
    
    func getOptionsList(completion: @escaping (([PrivateSubmenuOptionRepresentable]) -> Void)) {
        self.completion = completion
        guard let presenter = presenter else {
            return
        }
        UseCaseWrapper(with: presenter.useCaseProvider.getInfoServicesForYouUseCase(), useCaseHandler: presenter.useCaseHandler, errorHandler: presenter.genericErrorHandler, onSuccess: { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.servicesForYou = result.servicesForYou
            self?.addLocationOption()
        })
    }
    
    func selected(option: PrivateSubmenuOptionRepresentable) {
        guard let option = option as? MyServicesForYouOptionRepresentable else { return }
        navigator.closeSideMenu()
        if let category = option.category {
            navigator.goToServicesForYou(with: Category(category))
        } else {
            didSelectBanner(location: .TRAE_UN_AMIGO)
        }
        navigator.setFirstViewControllerToGP()
    }
    
    func didSelectBanner(location: PullOfferLocation) {
        if let offer = candidates?[location] {
            guard let offerAction = offer.action else { return }
            offerDelegate?.executeOffer(action: offerAction, offerId: offer.id, location: location)
        }
    }
}

extension SmartServicesHelper: LocationsResolver {
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
