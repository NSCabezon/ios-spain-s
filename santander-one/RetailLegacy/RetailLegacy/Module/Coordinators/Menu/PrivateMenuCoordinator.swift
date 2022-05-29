//
//  PrivateMenuCoordinator.swift
//  Account
//
//  Created by Juan Carlos López Robles on 12/17/21.
//

import UI
import CoreFoundationLib
import Foundation
import CoreDomain

final class PrivateMenuCoordinator: Coordinator {
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    private let dependencies: RetailLegacyMenuExternalDependenciesResolver

    init(dependencies: RetailLegacyMenuExternalDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    func start() {
        let drawer: BaseMenuViewController = dependencies.resolve()
        drawer.toggleSideMenu()
    }
}
