//
//  OpinatorCoordinator.swift
//  RetailLegacy
//
//  Created by Felipe Lloret on 20/3/22.
//

import CoreFoundationLib
import UI

final class OpinatorCoordinator: BindableCoordinator {
    var dataBinding: DataBinding = DataBindingObject()
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    private let dependencies: RetailLegacyPrivateMenuExternalDependenciesResolver
    private lazy var legacyDependencies: DependenciesResolver = dependencies.resolve()
    
    init(dependencies: RetailLegacyPrivateMenuExternalDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    public func start() {
        let opinator = RegularOpinatorInfoEntity(path: "appnew-general")
        legacyDependencies
            .resolve(for: OpinatorCoordinatorLauncher.self)
            .handleOpinator(opinator)
    }
}
