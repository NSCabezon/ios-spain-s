import CoreDomain
import CoreFoundationLib
import CoreDomain

final class MyProductsHelper {
    private var completion: (([PrivateSubmenuOptionRepresentable]) -> Void)?
    private weak var presenter: PrivateSubmenuPresenter?
    private var navigator: PrivateHomeNavigator
    private(set) weak var offerDelegate: PrivateSideMenuOfferDelegate?
    
    var privateMenuWrapper: PrivateMenuWrapper
    
    internal var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().myProductsSideMenu
    }
    
    init(privateMenuWrapper: PrivateMenuWrapper,
         presenter: PrivateSubmenuPresenter,
         navigator: PrivateHomeNavigator,
         offerDelegate: PrivateSideMenuOfferDelegate) {
        self.privateMenuWrapper = privateMenuWrapper
        self.presenter = presenter
        self.navigator = navigator
        self.offerDelegate = offerDelegate
    }
    
    private func wrapperUpdated() {
        var options: [PrivateMenuMyProductsOption] = privateMenuWrapper.isPb ? PrivateMenuMyProductsOption.pbOrder: PrivateMenuMyProductsOption.notPbOrder
        if privateMenuWrapper.isVisibleAccountsEmpty(), let index = options.firstIndex(of: .accounts) {
            options.remove(at: index)
        }
        if privateMenuWrapper.isCardsMenuEmpty(), let index = options.firstIndex(of: .cards) {
            options.remove(at: index)
        }
        if privateMenuWrapper.isStocksMenuEmpty(), let index = options.firstIndex(of: .stocks) {
            options.remove(at: index)
        }
        if privateMenuWrapper.isLoansMenuEmpty(), let index = options.firstIndex(of: .loans) {
            options.remove(at: index)
        }
        if privateMenuWrapper.isDepositsMenuEmpty(), let index = options.firstIndex(of: .deposits) {
            options.remove(at: index)
        }
        if privateMenuWrapper.isPensionsMenuEmpty() || !self.privateMenuWrapper.localAppConfig.enablePensionsHome, let index = options.firstIndex(of: .pensions) {
            options.remove(at: index)
        }
        if privateMenuWrapper.isFundsMenuEmpty(), let index = options.firstIndex(of: .funds) {
            options.remove(at: index)
        }
        if privateMenuWrapper.isInsuranceSavingMenuEmpty() || !self.privateMenuWrapper.localAppConfig.enableInsuranceSavingHome, let index = options.firstIndex(of: .insuranceSavings) {
            options.remove(at: index)
        }
        if privateMenuWrapper.isInsuranceProtectionMenuEmpty(), let index = options.firstIndex(of: .insuranceProtection) {
            options.remove(at: index)
        }
        getCandidateOffers { [weak self] candidates in
            if candidates[.MENU_TPV] != nil {
                options.append(.tpvs)
            }
            self?.completion?(options)
        }
    }
}

extension MyProductsHelper: LocationsResolver {
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

extension MyProductsHelper: PrivateMenuSectionHelper {
    var titleKey: String {
        return "menu_link_myProduct"
    }
    var sidebarProductsTitle: String? {
        return self.privateMenuWrapper.myProductsOffers
    }
    var hasTitle: Bool {
        return (self.presenter?.myProductsOptions.count ?? 0 > 0) ? true : false
    }
    
    func getOptionsList(completion: @escaping (([PrivateSubmenuOptionRepresentable]) -> Void)) {
        self.completion = completion
        self.wrapperUpdated()
    }
    
    func selected(option: PrivateSubmenuOptionRepresentable) {
        guard let option = option as? PrivateMenuMyProductsOption else { return }
        navigator.closeSideMenu()
        guard !privateMenuWrapper.localAppConfig.isPortugal else {
            self.isPortugalOptionSelected(option: option)
            return
        }
        if let productHome = productHomeFor(option: option) {
            self.presentHome(from: productHome)
        } else if option == .tpvs {
            offerDelegate?.didSelectBanner(location: PullOfferLocation.MENU_TPV)
        }
        navigator.setFirstViewControllerToGP()
    }
    
    func presentHome(from productHome: PrivateMenuProductHome) {
        switch productHome {
        case .accounts,
             .loans,
             .pensions,
             .funds,
             .deposits,
             .cards,
             .stocks:
            navigator.present(selectedProduct: nil, productHome: productHome)
        case .insuranceSavings,
             .insuranceProtection:
            self.presentInsurances(with: productHome)
        default:
            break
        }
    }
    
    func presentInsurances(with productHome: PrivateMenuProductHome) {
        if presenter?.insuranceDetailEnabled == true {
            navigator.present(selectedProduct: nil, productHome: productHome)
        } else {
            presenter?.presentInsurancesMessage()
        }
    }
    
    func isPortugalOptionSelected(option: PrivateMenuMyProductsOption) {
        guard let productHome = productHomeFor(option: option) else { return }
        guard productHome == .accounts || productHome == .cards || productHome == .loans else {
            navigator.showComingSoonToast()
            return
        }
        self.navigator.present(selectedProduct: nil, productHome: productHome)
        self.navigator.setFirstViewControllerToGP()
    }
    
    func titleForOption(_ option: PrivateSubmenuOptionRepresentable) -> String {
        let title = localized(option.titleKey).text
        guard let option = option as? PrivateMenuMyProductsOption else { return title }
        var value: Int?
        let products = self.privateMenuWrapper.products
        switch option {
        case .accounts:
            value = products[.account]?.productsRepresentable.filter({$0.value.isVisible}).count
        case .cards:
            value = products[.card]?.productsRepresentable.filter({$0.value.isVisible}).count
        case .deposits:
            value = products[.deposit]?.productsRepresentable.filter({$0.value.isVisible}).count
        case .funds:
            value = products[.fund]?.productsRepresentable.filter({$0.value.isVisible}).count
        case .insuranceProtection:
            value = products[.insuranceProtection]?.productsRepresentable.filter({$0.value.isVisible}).count
        case .insuranceSavings:
            value = products[.insuranceSaving]?.productsRepresentable.filter({$0.value.isVisible}).count
        case .loans:
            value = products[.loan]?.productsRepresentable.filter({$0.value.isVisible}).count
        case .pensions:
            value = products[.pension]?.productsRepresentable.filter({$0.value.isVisible}).count
        case .stocks:
            value = products[.stock]?.productsRepresentable.filter({$0.value.isVisible}).count
        case .savingProducts:
            value = products[.savingProduct]?.productsRepresentable.filter({$0.value.isVisible}).count
        case .tpvs:
            value = nil
        }
        guard
            let productNumber = value,
            productNumber > 0
            else { return title }
        
        let numberOfProducts = localized("generic_parenthesis_placeholder",
                                         [StringPlaceholder(.number, String(productNumber))]).text
        return "\(title) \(numberOfProducts)"
    }
}

private extension MyProductsHelper {
    func productHomeFor(option: PrivateMenuMyProductsOption) -> PrivateMenuProductHome? {
        switch option {
        case .accounts:
            return PrivateMenuProductHome.accounts
        case .cards:
            return PrivateMenuProductHome.cards
        case .stocks:
            return PrivateMenuProductHome.stocks
        case .deposits:
            return PrivateMenuProductHome.deposits
        case .loans:
            return PrivateMenuProductHome.loans
        case .pensions:
            return PrivateMenuProductHome.pensions
        case .funds:
            return PrivateMenuProductHome.funds
        case .insuranceSavings:
            return PrivateMenuProductHome.insuranceSavings
        case .insuranceProtection:
            return PrivateMenuProductHome.insuranceProtection
        case .savingProducts:
            return PrivateMenuProductHome.savingProducts
        case .tpvs:
            return nil
        }
    }
}
