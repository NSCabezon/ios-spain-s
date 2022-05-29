//
//  FundTransactionsCoordinator.swift
//  Funds
//
//  Created by Ernesto Fernandez Calles on 28/3/22.
//

import UI
import CoreDomain
import CoreFoundationLib

protocol FundTransactionsCoordinator: BindableCoordinator {
    func openMenu()
    func share(_ shareable: Shareable, type: ShareType)
    func goToFilter(with fund: FundRepresentable, filters: FundsFilterRepresentable?, filterOutsider: FundsFilterOutsider)
}

final class DefaultFundTransactionsCoordinator: FundTransactionsCoordinator {
    var onFinish: (() -> Void)?
    weak var navigationController: UINavigationController?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: FundTransactionsExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()

    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()

    public init(dependencies: FundTransactionsExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultFundTransactionsCoordinator {
    func start() {
        guard dataBinding.contains(FundRepresentable.self) else {
            return
        }
        navigationController?.blockingPushViewController(dependencies.resolve(), animated: true)
    }

    func share(_ shareable: Shareable, type: ShareType) {
        let coordinator: ShareCoordinator = dependencies.external.resolve()
        coordinator
            .set(shareable)
            .set(type)
            .start()
        append(child: coordinator)
    }

    func openMenu() {
        let coordinator = dependencies.external.privateMenuCoordinator()
        coordinator.start()
        append(child: coordinator)
    }

    func goToFilter(with fund: FundRepresentable, filters: FundsFilterRepresentable?, filterOutsider: FundsFilterOutsider) {
        let coordinator = dependencies.external.fundsTransactionsFilterCoordinator()
        coordinator
            .set(fund)
            .set(filterOutsider)
            .set(filters)
            .start()
        append(child: coordinator)
    }
}

private extension DefaultFundTransactionsCoordinator {
    struct Dependency: FundTransactionsDependenciesResolver {
        let dependencies: FundTransactionsExternalDependenciesResolver
        let coordinator: FundTransactionsCoordinator
        let dataBinding = DataBindingObject()

        var external: FundTransactionsExternalDependenciesResolver {
            return dependencies
        }

        func resolve() -> FundTransactionsCoordinator {
            return coordinator
        }

        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
