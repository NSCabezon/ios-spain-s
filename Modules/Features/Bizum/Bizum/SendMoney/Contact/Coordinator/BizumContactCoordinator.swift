//
//  BizumContactCoordinator.swift
//  Bizum
//
//  Created by José Carlos Estela Anguita on 26/1/21.
//

import UI
import CoreFoundationLib

protocol BizumContactCoordinatorProtocol {
    func goToAccountSelector(delegate: BizumSendMoneyAccountSelectorCoordinatorDelegate)
}

final class BizumContactCoordinator: BizumContactCoordinatorProtocol {
    
    weak var navigationController: UINavigationController?
    private let dependencies: DependenciesResolver & DependenciesInjector
    let accountSelectorCoordinator: BizumSendMoneyAccountSelectorCoordinator
    
    init(navigationController: UINavigationController, dependenciesResolver: DependenciesResolver) {
        self.navigationController = navigationController
        self.dependencies = DependenciesDefault(father: dependenciesResolver)
        self.accountSelectorCoordinator = BizumSendMoneyAccountSelectorCoordinator(navigationController: navigationController, dependenciesResolver: self.dependencies)
    }
    
    func goToAccountSelector(delegate: BizumSendMoneyAccountSelectorCoordinatorDelegate) {
        self.dependencies.register(for: BizumSendMoneyAccountSelectorCoordinatorDelegate.self) { _ in
            return delegate
        }
        self.accountSelectorCoordinator.start()
    }
}
