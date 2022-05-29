//
//  MenuHomeNavigator.swift
//  RetailCleanTests
//
//  Created by Cristobal Ramos Laina on 15/09/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib
import Menu

final class MenuHomeNavigator {
    private let presenterProvider: PresenterProvider
    private let drawer: BaseMenuViewController
    private let dependenciesEngine: DependenciesResolver
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
        self.dependenciesEngine = dependenciesEngine
    }
    
    func gotoFinancingCards() {
        let navigatorViewController = self.drawer.currentRootViewController as? UINavigationController ?? UINavigationController()
        
        let menuModuleCoordinator = MenuModuleCoordinator(
            dependenciesResolver: dependenciesEngine,
            navigationController: navigatorViewController
        )
        
        self.presenterProvider.dependenciesEngine.register(for: CardFinanceableTransactionConfiguration.self) { _ in
            return CardFinanceableTransactionConfiguration(selectedCard: nil)
        }
        
        self.presenterProvider.dependenciesEngine.register(for: FinanceableTransactionCoordinatorDelegate.self) {_ in
            return self.presenterProvider.navigatorProvider.getModuleCoordinator(type: MenuCoordinatorNavigator.self)
        }
        
        menuModuleCoordinator.start(.cardFinanceableTransactions)
    }
}
