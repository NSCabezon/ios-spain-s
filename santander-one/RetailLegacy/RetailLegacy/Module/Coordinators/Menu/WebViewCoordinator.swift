//
//  WebViewCoordinator.swift
//  RetailLegacy
//
//  Created by Manuel Martínez del Rey on 4/4/22.
//

import UI
import CoreFoundationLib
import CoreDomain

final class WebViewCoordinator: BindableCoordinator {
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
        guard let configuration: WebViewConfiguration = dataBinding.get() else { return }
        legacyDependencies
            .resolve(for: NavigatorProvider.self)
            .privateHomeNavigator
            .goToWebView(configuration: configuration, type: nil, didCloseClosure: nil)
    }
}
