//
//  ProductsNavigator.swift
//  RetailLegacy
//
//  Created by David Gálvez Alonso on 04/02/2021.
//

import CoreFoundationLib
import Account
import Cards
import Loans
import Funds
import SavingProducts
import CoreDomain

protocol ProductsNavigatorProtocol {
    func showCardsHome(with selected: CardEntity?, cardSection: CardsModuleCoordinator.CardsSection)
    func showAccountsHome(with selected: AccountEntity?, accountSection: AccountsModuleCoordinator.AccountsSection)
    func showLoansHome(with selected: LoanEntity?)
    func presentProduct(selectedProduct: GenericProduct?, productHome: PrivateMenuProductHome, overCurrentController: Bool?)
}

final class ProductsNavigator {
    
    private weak var navigationController: NavigationController?
    private let presenterProvider: PresenterProvider
    private let drawer: BaseMenuViewController
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    private let accountsCoordinator: AccountsModuleCoordinator
    private let cardsCoordinator: CardsModuleCoordinator
    private let legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver
    private let cardExternalDependenciesResolver: CardExternalDependenciesResolver
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver & DependenciesInjector, legacyExternalDependenciesResolver: RetailLegacyExternalDependenciesResolver, cardExternalDependenciesResolver: CardExternalDependenciesResolver) {
        self.cardExternalDependenciesResolver = cardExternalDependenciesResolver
        self.legacyExternalDependenciesResolver = legacyExternalDependenciesResolver
        self.navigationController = drawer.currentRootViewController as? NavigationController
        self.presenterProvider = presenterProvider
        self.drawer = drawer
        self.dependenciesEngine = dependenciesEngine        
        self.cardsCoordinator = CardsModuleCoordinator(dependenciesResolver: presenterProvider.dependenciesEngine, navigationController: navigationController ?? UINavigationController(), externalDependencies: cardExternalDependenciesResolver)
        self.accountsCoordinator = AccountsModuleCoordinator(dependenciesResolver: presenterProvider.dependenciesEngine, navigationController: navigationController ?? UINavigationController())
    }
}

extension ProductsNavigator: ProductsNavigatorProtocol {
    func showCardsHome(with selected: CardEntity?, cardSection: CardsModuleCoordinator.CardsSection = .home) {
        self.presenterProvider.dependenciesEngine.register(for: CardsHomeConfiguration.self) { _ in
            return CardsHomeConfiguration(selectedCard: selected)
        }
        self.presenterProvider.dependenciesEngine.register(for: CardsHomeModuleCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: CardsHomeCoordinatorNavigator.self)
        }
        self.presenterProvider.dependenciesEngine.register(for: CardsHomeCoordinatorNavigator.self) { _ in
            self.presenterProvider.navigatorProvider.getModuleCoordinator(type: CardsHomeCoordinatorNavigator.self)
        }
        
        self.presenterProvider.dependenciesEngine.register(for: CardBoardingCoordinatorDelegate.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: CardsHomeCoordinatorNavigator.self)
        }
        self.cardsCoordinator.start(cardSection)
    }
    
    func showAccountsHome(with selected: AccountEntity?, accountSection: AccountsModuleCoordinator.AccountsSection = .home) {
        let moduleCoordinator = self.presenterProvider.navigatorProvider.getModuleCoordinator(type: AccountsHomeCoordinatorNavigator.self)
        self.presenterProvider.dependenciesEngine.register(for: AccountsHomeConfiguration.self) { dependenciesResolver in
            let appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
            let isScaForTransactionsEnabled = appConfigRepository.getBool(DomainConstant.appConfigEnableSCAAccountTransactions) == true
            return AccountsHomeConfiguration(selectedAccount: selected, isScaForTransactionsEnabled: isScaForTransactionsEnabled)
        }
        self.presenterProvider.dependenciesEngine.register(for: AccountsHomeCoordinatorDelegate.self) { _ in
            return moduleCoordinator
        }
        self.presenterProvider.dependenciesEngine.register(for: AccountTransactionDetailCoordinatorDelegate.self) { _ in
            return moduleCoordinator
        }
        self.accountsCoordinator.start(accountSection)
    }

    func showLoansHome(with selected: LoanEntity?) {
        self.presenterProvider.dependenciesEngine.register(for: LoansHomeCoordinatorNavigator.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: LoansHomeCoordinatorNavigator.self)
        }
        legacyExternalDependenciesResolver
            .loanHomeCoordinator()
            .set(selected?.representable)
            .start()
    }

    func showFundsHome(with selected: FundEntity?) {
        self.presenterProvider.dependenciesEngine.register(for: FundsHomeCoordinatorNavigator.self) { _ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: FundsHomeCoordinatorNavigator.self)
        }

        legacyExternalDependenciesResolver
            .fundsHomeCoordinator()
            .set(selected?.representable)
            .start()
    }
    
    func showSavingsHome(with selected: SavingProductEntity?) {
        legacyExternalDependenciesResolver
            .savingsHomeCoordinator()
            .set(selected?.representable)
            .start()
    }
    
    func presentProduct(selectedProduct: GenericProduct? = nil, productHome: PrivateMenuProductHome, overCurrentController: Bool?) {
        switch productHome {
        case .cards:
            self.showCardsHome(with: (selectedProduct as? Card)?.cardEntity)
        case .loans:
            self.showLoansHome(with: (selectedProduct as? Loan)?.loanEntity)
        case .funds:
            self.showFundsHome(with: (selectedProduct as? Fund)?.fundEntity)
        case .accounts:
            self.showAccountsHome(with: (selectedProduct as? Account)?.accountEntity)
        case .savingProducts:
            self.showSavingsHome(with: (selectedProduct as? SavingProduct)?.savingProductEntity)
        default:
            self.presentOverCurrentController(selectedProduct: selectedProduct, productHome: productHome, overCurrentController: overCurrentController ?? false)
        }
    }
}

private extension ProductsNavigator {
    func showProductHomeViewController(_ vc: UIViewController, overCurrentController: Bool) {
        guard let navigator = drawer.currentRootViewController as? NavigationController else {
            return
        }
        guard overCurrentController else {
            if let globalPositionVC = navigator.viewControllers.first {
                navigator.setViewControllers([globalPositionVC, vc], animated: true)
            }
            return
        }
        navigator.pushViewController(vc, animated: true)
    }
    
    func presentOverCurrentController(selectedProduct: GenericProduct? = nil, productHome: PrivateMenuProductHome, overCurrentController: Bool) {
        let productPresenter: ProductHomePresenter
        switch productHome {
        case .stocks:
            productPresenter = self.presenterProvider.productHomePresenterStocks
        case .managedRVPortfolios:
            productPresenter = self.presenterProvider.productHomePresenterManagedRVStocks
        case .notManagedRVPortfolios:
            productPresenter = self.presenterProvider.productHomePresenterNotManagedRVStocks
        default:
            productPresenter = self.presenterProvider.productHomePresenter
        }
        productPresenter.productHome = productHome
        productPresenter.selectedProduct = selectedProduct
        self.showProductHomeViewController(productPresenter.view, overCurrentController: overCurrentController)
    }
}
