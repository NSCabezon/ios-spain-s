//
//  SecurityCoordinator.swift
//  RetailLegacy
//
//  Created by Boris Chirino Fernandez on 1/2/22.
//

import UI
import CoreFoundationLib

final public class SecurityCoordinator: BindableCoordinator {
    public var dataBinding: DataBinding = DataBindingObject()
    public var onFinish: (() -> Void)?
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController?
    private let resolver: RetailLegacyPrivateMenuExternalDependenciesResolver
    private lazy var legacyDependencies: DependenciesResolver = resolver.resolve()

    public init(dependencies: RetailLegacyPrivateMenuExternalDependenciesResolver) {
        self.resolver = dependencies
    }
    
    public func start() {
        legacyDependencies
            .resolve(for: NavigatorProvider.self)
            .privateHomeNavigator.goToSecurityArea()
    }
}
