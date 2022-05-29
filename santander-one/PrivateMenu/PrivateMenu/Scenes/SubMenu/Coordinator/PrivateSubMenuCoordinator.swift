import UI
import CoreFoundationLib
import CoreDomain

public protocol PrivateSubMenuCoordinator: BindableCoordinator {
    func gotoSecurity()
    func gotoBranchLocator()
    func gotoHelpCenter()
    func gotoMyManager()
    func toggleSideMenu()
    func goToPrivateOffer(offer: OfferRepresentable)
    func goToAccounts()
    func goToCards()
    func goToSavingProducts()
    func goToStocks()
    func goToDeposits()
    func goToLoans()
    func goToPensions()
    func goToFunds()
    func goToManagedPortfolios()
    func goToNotManagedPortfolios()
    func goToManagedRVPortfolios()
    func goToNotManagedRVPortfolios()
    func goToInsuranceSavings()
    func goToInsuranceProtection()
    func goToProductProfileFund()
    func goToProductProfilePlans()
    func goToProductProfileVariableIncomeNotManaged()
    func goToProductProfileVariableIncomeManaged()
    func goToProductProfileTransaction()
    func goToImpositionsHome()
    func goToImpositionTransactionDetail()
    func goToImposition()
    func goToPortfolioProductDetail()
    func goToPortfolioProductTransactionDetail()
    func goToLiquidation()
    func goToLiquidationDetail()
    func goToOrders()
    func goToCardDispensation()
    func goToCardsPending()
    func goToBill()
    func goToSofiaInvestments()
    func showOldDialog(_ message: String)
    func goToVariableIncome()
    func goToStockholders()
    func goToComingSoon()
    func gotoOpinator()
}

final class DefaultPrivateSubMenuCoordinator: PrivateSubMenuCoordinator {
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    
    lazy var dataBinding: DataBinding = dependencies.resolve()
    private lazy var dependencies: Dependency = {
        Dependency(externalDependency: externalDependencies, coordinator: self)
    }()
    private let externalDependencies: PrivateSubMenuExternalDependenciesResolver

    public init(dependencies: PrivateSubMenuExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultPrivateSubMenuCoordinator {
    func start() {
        let viewController: PrivateSubMenuViewController = dependencies.resolve()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func gotoSecurity() {
        let securityCoordinator = dependencies.external.securityCoordinator()
        gotoCoordinator(securityCoordinator)
    }
    
    func gotoBranchLocator() {
        let branchCoordinator = dependencies.external.branchLocatorCoordinator()
        gotoCoordinator(branchCoordinator)
    }
    
    func gotoHelpCenter() {
        guard let privateMenuModifier = dependencies.external.resolve().resolve(forOptionalType: PrivateMenuProtocol.self) else {
            let coordinator = dependencies.external.helpCenterCoordinator()
            gotoCoordinator(coordinator)
            return
        }
        toggleSideMenu()
        privateMenuModifier.goToHelpCenterPage()
    }
    
    func gotoMyManager() {
        let managerCoordinator = dependencies.external.myManagerCoordinator()
        gotoCoordinator(managerCoordinator)
    }
    
    func toggleSideMenu() {
        let outsider: PrivateMenuToggleOutsider = dependencies.external.resolve()
        outsider.toggleSideMenu()
    }
    
    func goToPrivateOffer(offer: OfferRepresentable) {
        let coordinator = dependencies.external.resolveOfferCoordinator()
            .set(offer)
        gotoCoordinator(coordinator)
    }
    
    func goToAccounts() {
        let coordinator = dependencies.external.accountsHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToCards() {
        let coordinator = dependencies.external.cardsHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToSavingProducts() {
        let coordinator = dependencies.external.savingProductsHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToStocks() {
        let coordinator = dependencies.external.stocksHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToDeposits() {
        let coordinator = dependencies.external.depositsHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToLoans() {
        let coordinator = dependencies.external.loansHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToPensions() {
        let coordinator = dependencies.external.pensionsHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToFunds() {
        let coordinator = dependencies.external.fundsHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToManagedPortfolios() {
        let coordinator = dependencies.external.managedPortfoliosHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToNotManagedPortfolios() {
        let coordinator = dependencies.external.notManagedPortfoliosHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToManagedRVPortfolios() {
        let coordinator = dependencies.external.managedRVPortfoliosHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToNotManagedRVPortfolios() {
        let coordinator = dependencies.external.notManagedRVPortfoliosHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToInsuranceSavings() {
        let coordinator = dependencies.external.insuranceSavingsHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToInsuranceProtection() {
        let coordinator = dependencies.external.insuranceProtectionHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToProductProfileFund() {
        let coordinator = dependencies.external.productProfileFundHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToProductProfilePlans() {
        let coordinator = dependencies.external.productProfilePlansHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToProductProfileVariableIncomeNotManaged() {
        let coordinator = dependencies.external.productProfileVariableIncomeNotManagedHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToProductProfileVariableIncomeManaged() {
        let coordinator = dependencies.external.productProfileVariableIncomeManagedHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToProductProfileTransaction() {
        let coordinator = dependencies.external.productProfileTransactionHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToImpositionsHome() {
        let coordinator = dependencies.external.impositionsHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToImpositionTransactionDetail() {
        let coordinator = dependencies.external.impositionTransactionDetailCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToImposition() {
        let coordinator = dependencies.external.impositionDetailCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToPortfolioProductDetail() {
        let coordinator = dependencies.external.portfolioProductDetailCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToPortfolioProductTransactionDetail() {
        let coordinator = dependencies.external.portfolioProductTransactionDetailCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToLiquidation() {
        let coordinator = dependencies.external.liquidationHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToLiquidationDetail() {
        let coordinator = dependencies.external.liquidationDetailCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToOrders() {
        let coordinator = dependencies.external.ordersHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToCardDispensation() {
        let coordinator = dependencies.external.cardDispensationHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToCardsPending() {
        let coordinator = dependencies.external.cardsPendingHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToBill() {
        let coordinator = dependencies.external.billHomeCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToSofiaInvestments() {
        let coordinator = dependencies.external.sofiaInvestmentsCoordinator()
        gotoCoordinator(coordinator)
    }
    
    func goToVariableIncome() {
        let coordinator = dependencies.external.privateSubMenuVariableIncome()
        gotoCoordinator(coordinator)
    }
    
    func goToStockholders() {
        let coordinator = dependencies.external.privateSubMenuStockholders()
        gotoCoordinator(coordinator)
    }
    
    func goToComingSoon() {
        let coordinator = dependencies.external.privateMenuComingSoon()
        gotoCoordinator(coordinator)
    }
    
    func showOldDialog(_ message: String) {
        toggleSideMenu()
        let acceptAction = DialogButtonComponents(titled: localized("generic_button_accept"), does: nil)
        self.showOldDialog(
            title: nil,
            description: localized(message),
            acceptAction: acceptAction,
            cancelAction: nil,
            isCloseOptionAvailable: false
        )
    }
    
    func gotoOpinator() {
        let coordinator = dependencies.external.privateMenuOpinatorCoordinator()
        gotoCoordinator(coordinator)
    }
}

extension DefaultPrivateSubMenuCoordinator: OldDialogViewPresentationCapable {
    var associatedOldDialogView: UIViewController {
        return dependencies.external.resolve() as UINavigationController
    }
    var associatedGenericErrorDialogView: UIViewController {
        return dependencies.external.resolve() as UINavigationController
    }
}

private extension DefaultPrivateSubMenuCoordinator {
    class Dependency: PrivateSubMenuDependenciesResolver {
        let coordinator: DefaultPrivateSubMenuCoordinator
        let dataBinding = DataBindingObject()
        let dependencies: PrivateSubMenuExternalDependenciesResolver
        
        var external: PrivateSubMenuExternalDependenciesResolver {
            return dependencies
        }
        
        init(externalDependency: PrivateSubMenuExternalDependenciesResolver,
             coordinator: DefaultPrivateSubMenuCoordinator) {
            self.dependencies = externalDependency
            self.coordinator = coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
        
        func resolve() -> PrivateSubMenuCoordinator {
            return coordinator
        }
    }
    
    func dismissMenu() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func gotoCoordinator(_ coordinator: BindableCoordinator, dismissMenu: Bool = true) {
        if dismissMenu {
            toggleSideMenu()
        }
        coordinator.start()
        append(child: coordinator)
    }
}
