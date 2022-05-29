//
//  BizumHomeNavigator.swift
//  RetailClean
//
//  Created by Carlos Gutiérrez Casado on 08/09/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib
import Bizum
import RetailLegacy

final class BizumHomeNavigator {
    private var drawer: BaseMenuViewController
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    
    required init(drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver & DependenciesInjector) {
        self.dependenciesEngine = dependenciesEngine
        self.drawer = drawer
    }
}

extension BizumHomeNavigator {
    func gotoBizumHome(_ configuration: BizumCheckPaymentConfiguration) {
        let navigationController = self.drawer.currentRootViewController as? UINavigationController ?? UINavigationController()
        let bizumCoordinator = BizumModuleCoordinator(dependenciesResolver: dependenciesEngine,
                                                      navigationController: navigationController)
        dependenciesEngine.register(for: BizumCheckPaymentConfiguration.self) {_ in
            return configuration
        }
        bizumCoordinator.start(.home)
    }
}
