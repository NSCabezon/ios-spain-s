//
//  BranchLocatorCoordinator.swift
//  RetailLegacy
//
//  Created by Boris Chirino Fernandez on 1/2/22.
//

import UI
import CoreFoundationLib

final class BranchLocatorCoordinator: BindableCoordinator {
    var dataBinding: DataBinding = DataBindingObject()
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    private let dependencies: RetailLegacyPrivateMenuExternalDependenciesResolver
    private lazy var legacyDependencies: DependenciesResolver = dependencies.resolve()

    init(dependencies: RetailLegacyPrivateMenuExternalDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    func start() {
        let localAppConfig = legacyDependencies.resolve(for: LocalAppConfig.self)
        let privateHomeNavigator = legacyDependencies
            .resolve(for: NavigatorProvider.self)
            .privateHomeNavigator
        if localAppConfig.showATMIntermediateScreen {
            privateHomeNavigator.goToAtm()
        } else {
            privateHomeNavigator.goToATMLocator(keepingNavigation: true)
        }
    }
}
