//
//  StockholderNavigatable.swift
//  RetailClean
//
//  Created by alvola on 28/04/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import UIKit
import CoreFoundationLib
import Menu

protocol StockholderNavigatable {
    var customNavigation: NavigationController? { get }
    var dependenciesResolver: DependenciesResolver { get }
    func goToStockholders()
}

extension StockholderNavigatable {
    func presentStockholders() {
        guard let navigator = customNavigation, let first = navigator.viewControllers.first  else { return }
        navigator.isProgressBarVisible = false
        navigator.setViewControllers([first], animated: false)
        let coordinator = dependenciesResolver.resolve(for: RetailLegacyExternalDependenciesResolver.self).publicMenuStockholdersCoordinator()
        coordinator.start()
    }
}
