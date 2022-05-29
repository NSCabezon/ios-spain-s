//
//  BizumNavigationDependencies.swift
//  Santander
//
//  Created by Carlos Monfort Gómez on 13/4/21.
//

import UIKit
import CoreFoundationLib
import Ecommerce
import RetailLegacy
import Bizum

final class BizumNavigationDependencies {
    private let drawer: BaseMenuViewController
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    
    private lazy var bizumHomeCoordinatorNavigator: BizumHomeModuleCoordinatorDelegate & BizumStartCapable & SplitExpensesCoordinatorLauncher = {
        return BizumHomeCoordinatorNavigator(drawer: self.drawer, dependenciesEngine: dependenciesEngine)
    }()
    
    init(drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver & DependenciesInjector) {
        self.drawer = drawer
        self.dependenciesEngine = dependenciesEngine
    }
    
    func registerDependencies() {
        self.dependenciesEngine.register(for: BizumStartCapable.self) { _ in
            return self.bizumHomeCoordinatorNavigator
        }
        self.dependenciesEngine.register(for: BizumHomeModuleCoordinatorDelegate.self) { _ in
            return self.bizumHomeCoordinatorNavigator
        }
        self.dependenciesEngine.register(for: BizumHomeNavigator.self) { _ in
            return BizumHomeNavigator(drawer: self.drawer, dependenciesEngine: self.dependenciesEngine)
        }
        self.dependenciesEngine.register(for: BizumModuleCoordinatorProtocol.self) { resolver in
            return BizumModuleCoordinator(dependenciesResolver: resolver, navigationController: self.drawer.viewController.navigationController)
        }
        self.dependenciesEngine.register(for: SplitExpensesCoordinatorLauncher.self) { _ in
            return self.bizumHomeCoordinatorNavigator
        }
    }
}
