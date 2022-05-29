//
//  OurProductsNavigatable.swift
//  RetailClean
//
//  Created by alvola on 29/04/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import UIKit
import CoreFoundationLib
import Menu

protocol OurProductsNavigatable {
    var customNavigation: NavigationController? { get }
    var dependenciesResolver: DependenciesResolver { get }
    func goToOurProducts()
}

extension OurProductsNavigatable {
    func presentOurProducts() {
        guard let navigator = customNavigation, let first = navigator.viewControllers.first  else { return }
        navigator.isProgressBarVisible = false
        navigator.setViewControllers([first], animated: false)
        let coordinator = dependenciesResolver.resolve(for: RetailLegacyExternalDependenciesResolver.self).publicMenuOurProductsCoordinator()
        coordinator.start()
    }
}
