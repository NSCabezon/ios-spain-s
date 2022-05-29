//
//  TopUpCoordinator.swift
//  RetailLegacy
//
//  Created by Boris Chirino Fernandez on 1/3/22.
//

import UI
import CoreFoundationLib

final class TopUpCoordinator: BindableCoordinator {
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
        guard let privateMenuModifier = self.legacyDependencies.resolve(forOptionalType: PrivateMenuProtocol.self) else { return }
        privateMenuModifier
            .goToTopUpLandingPage()
    }
}
