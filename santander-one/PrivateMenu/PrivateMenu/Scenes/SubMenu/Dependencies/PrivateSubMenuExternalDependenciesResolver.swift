import UI
import CoreFoundationLib
import CoreDomain

public protocol PrivateSubMenuExternalDependenciesResolver {
    func privateSubMenuCoordinator() -> BindableCoordinator
    func resolve() -> DependenciesResolver
    func resolve() -> UINavigationController
    func resolveSideMenuNavigationController() -> UINavigationController
    func resolve() -> GetPrivateMenuFooterOptionsUseCase
    func resolve() -> GetPersonalManagerUseCase
    func resolve() -> PrivateMenuToggleOutsider
    func resolve() -> GetMyProductSubMenuUseCase
    func resolve() -> GetOtherServicesSubMenuUseCase
    func resolve() -> GetSofiaInvestmentSubMenuUseCase
    func resolve() -> GetWorld123SubMenuUseCase
    func resolve() -> GetInsuranceDetailEnabledUseCase
    func resolve() -> GetCandidateOfferUseCase
    func securityCoordinator() -> BindableCoordinator
    func branchLocatorCoordinator() -> BindableCoordinator
    func helpCenterCoordinator() -> BindableCoordinator
    func myManagerCoordinator() -> BindableCoordinator
    func resolve() -> ReactivePullOffersInterpreter
    func resolveOfferCoordinator() -> BindableCoordinator
    func privateSubMenuActionCoordinator() -> BindableCoordinator
    func accountsHomeCoordinator() -> BindableCoordinator
    func cardsHomeCoordinator() -> BindableCoordinator
    func stocksHomeCoordinator() -> BindableCoordinator
    func depositsHomeCoordinator() -> BindableCoordinator
    func loansHomeCoordinator() -> BindableCoordinator
    func pensionsHomeCoordinator() -> BindableCoordinator
    func fundsHomeCoordinator() -> BindableCoordinator
    func managedPortfoliosHomeCoordinator() -> BindableCoordinator
    func notManagedPortfoliosHomeCoordinator() -> BindableCoordinator
    func managedRVPortfoliosHomeCoordinator() -> BindableCoordinator
    func notManagedRVPortfoliosHomeCoordinator() -> BindableCoordinator
    func insuranceSavingsHomeCoordinator() -> BindableCoordinator
    func insuranceProtectionHomeCoordinator() -> BindableCoordinator
    func productProfileFundHomeCoordinator() -> BindableCoordinator
    func productProfilePlansHomeCoordinator() -> BindableCoordinator
    func productProfileVariableIncomeNotManagedHomeCoordinator() -> BindableCoordinator
    func productProfileVariableIncomeManagedHomeCoordinator() -> BindableCoordinator
    func productProfileTransactionHomeCoordinator() -> BindableCoordinator
    func impositionsHomeCoordinator() -> BindableCoordinator
    func impositionTransactionDetailCoordinator() -> BindableCoordinator
    func impositionDetailCoordinator() -> BindableCoordinator
    func portfolioProductDetailCoordinator() -> BindableCoordinator
    func portfolioProductTransactionDetailCoordinator() -> BindableCoordinator
    func liquidationHomeCoordinator() -> BindableCoordinator
    func liquidationDetailCoordinator() -> BindableCoordinator
    func ordersHomeCoordinator() -> BindableCoordinator
    func cardDispensationHomeCoordinator() -> BindableCoordinator
    func cardsPendingHomeCoordinator() -> BindableCoordinator
    func billHomeCoordinator() -> BindableCoordinator
    func sofiaInvestmentsCoordinator() -> BindableCoordinator
    func savingProductsHomeCoordinator() -> BindableCoordinator
    func privateSubMenuVariableIncome() -> BindableCoordinator
    func privateSubMenuStockholders() -> BindableCoordinator
    func privateMenuComingSoon() -> BindableCoordinator
    func privateMenuOpinatorCoordinator() -> BindableCoordinator
}

public extension PrivateSubMenuExternalDependenciesResolver {
    func privateSubMenuCoordinator() -> BindableCoordinator {
        return DefaultPrivateSubMenuCoordinator(dependencies: self,
                                                navigationController: resolveSideMenuNavigationController())
    }
    
    func resolve() -> GetPrivateMenuFooterOptionsUseCase {
        return DefaultMenuFooterOptionsUseCase()
    }
    
    func resolve() -> GetMyProductSubMenuUseCase {
        return DefaultPrivateSubMenuOptionsUseCase()
    }
    
    func resolve() -> GetOtherServicesSubMenuUseCase {
        return DefaultPrivateSubMenuOptionsUseCase()
    }
    
    func resolve() -> GetSofiaInvestmentSubMenuUseCase {
        return DefaultPrivateSubMenuOptionsUseCase()
    }
    
    func resolve() -> GetWorld123SubMenuUseCase {
        return DefaultPrivateSubMenuOptionsUseCase()
    }
    
    func resolve() -> GetInsuranceDetailEnabledUseCase {
        return DefaultGetInsuranceDetailEnabledUseCase()
    }
}
// MARK: - GoToMyProducts Functions

public extension PrivateSubMenuExternalDependenciesResolver {
    func accountsHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .accounts
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func cardsHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .cards
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func stocksHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .stocks
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func depositsHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .deposits
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func loansHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .loans
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func pensionsHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .pensions
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func managedPortfoliosHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .managedPortfolios
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func notManagedPortfoliosHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .notManagedPortfolios
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func managedRVPortfoliosHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .managedRVPortfolios
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func notManagedRVPortfoliosHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .notManagedRVPortfolios
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func insuranceSavingsHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .insuranceSavings
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func insuranceProtectionHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .insuranceProtection
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func productProfileFundHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .productProfileFund
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func productProfilePlansHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .productProfilePlans
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func productProfileVariableIncomeNotManagedHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .productProfileVariableIncomeNotManaged
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func productProfileVariableIncomeManagedHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .productProfileVariableIncomeManaged
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func productProfileTransactionHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .productProfileTransaction
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func impositionsHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .impositionsHome
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func impositionTransactionDetailCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .impositionTransactionDetail
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func impositionDetailCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .impositionDetail
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func portfolioProductDetailCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .portfolioProductDetail
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func portfolioProductTransactionDetailCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .portfolioProductTransactionDetail
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func liquidationHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .liquidation
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func liquidationDetailCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .liquidationDetail
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func ordersHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .orders
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func cardDispensationHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .cardDispensation
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func cardsPendingHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .cardsPending
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func billHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .bill
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func sofiaInvestmentsCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .sofiaInvestments
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
    
    func savingProductsHomeCoordinator() -> BindableCoordinator {
        let option: PrivateMenuProductHome = .savingProducts
        let coordinator = privateSubMenuActionCoordinator()
            .set(option)
        return coordinator
    }
}
