//
//  PersonalManagerCoordinator.swift
//  RetailLegacy
//
//  Created by Boris Chirino Fernandez on 22/2/22.
//

import UI
import CoreFoundationLib

final class PersonalManagerCoordinator: BindableCoordinator {
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
        legacyDependencies
            .resolve(for: NavigatorProvider.self)
            .privateHomeNavigator.goToManager()
    }
}

