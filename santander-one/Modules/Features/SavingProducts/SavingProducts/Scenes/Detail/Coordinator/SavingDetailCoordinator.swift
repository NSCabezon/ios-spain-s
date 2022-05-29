//
//  SavingDetailCoordinator.swift
//  SavingProducts
//
//  Created by Marcos Álvarez Mesa on 25/4/22.
//

import UI
import CoreFoundationLib
import Foundation
import CoreDomain

public protocol SavingDetailCoordinator: BindableCoordinator {
    func didSelectMenu()
    func share( _ shareable: Shareable, type: ShareType)
    func open(url: String)
}

final class DefaultSavingDetailCoordinator: SavingDetailCoordinator {
    var onFinish: (() -> Void)?
    weak var navigationController: UINavigationController?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: SavingDetailExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()

    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()

    public init(dependencies: SavingDetailExternalDependenciesResolver,
                navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }

    func didSelectMenu() {
        let coordinator = dependencies.external.privateMenuCoordinator()
        coordinator.start()
        append(child: coordinator)
    }

    func share( _ shareable: Shareable, type: ShareType) {
        let coordinator: ShareCoordinator = dependencies.external.resolve()
        coordinator
            .set(shareable)
            .set(type)
            .start()
        append(child: coordinator)
    }

    func open(url: String) {
        guard let url = URL(string: url),
                UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}

extension DefaultSavingDetailCoordinator {
    func start() {
        guard dataBinding.contains(SavingProductRepresentable.self) else { return }
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
}

private extension DefaultSavingDetailCoordinator {
    struct Dependency: SavingDetailDependenciesResolver {
        let dependencies: SavingDetailExternalDependenciesResolver
        let coordinator: SavingDetailCoordinator
        let dataBinding = DataBindingObject()

        var external: SavingDetailExternalDependenciesResolver {
            return dependencies
        }

        func resolve() -> SavingDetailCoordinator {
            return coordinator
        }

        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
