//
//  GlobalSearchCoordinator.swift
//  Account
//
//  Created by Juan Carlos López Robles on 12/17/21.
//

import UI
import CoreFoundationLib
import Foundation
import CoreDomain

final class GlobalSearchCoordinator: Coordinator {
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    private let dependencies: RetailLegacyMenuExternalDependenciesResolver
    private lazy var legacyDependencies: DependenciesResolver = dependencies.resolve()

    init(dependencies: RetailLegacyMenuExternalDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    func start() {
        let navigatorProvider: NavigatorProvider = legacyDependencies.resolve()
        navigatorProvider.privateHomeNavigator.goToGlobalSearch()
    }
}
