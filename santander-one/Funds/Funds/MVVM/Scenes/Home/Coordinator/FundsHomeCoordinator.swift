//
//  FundsHomeCoordinator.swift
//  Funds
//  

import UI
import CoreDomain
import CoreFoundationLib

protocol FundsHomeCoordinator: BindableCoordinator {
    func openMenu()
    func gotoGlobalSearch()
    func gotoFundCustomeOption(with fund: FundRepresentable, option: FundOptionRepresentable)
    func share(_ shareable: Shareable, type: ShareType)
    func showProfitabilityTooltip()
    func gotoTransactions(with fund: FundRepresentable)
}

final class DefaultFundsHomeCoordinator: FundsHomeCoordinator {
    var onFinish: (() -> Void)?
    weak var navigationController: UINavigationController?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: FundsHomeExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()

    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()

    public init(dependencies: FundsHomeExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultFundsHomeCoordinator {
    func start() {
        self.navigationController?.pushViewController(dependencies.resolve(), animated: true)
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

    func gotoGlobalSearch() {
        let coordinator = dependencies.external.globalSearchCoordinator()
        coordinator.start()
        append(child: coordinator)
    }

    func gotoFundCustomeOption(with fund: FundRepresentable, option: FundOptionRepresentable) {
        let coordinator = dependencies.external.fundCustomeOptionCoordinator()
        coordinator
            .set(fund)
            .set(option)
            .start()
        append(child: coordinator)
    }

    func showProfitabilityTooltip() {
        let profitabilityTooltip = ProfitabilityTooltipView(externalDependencies)
        profitabilityTooltip.modalPresentationStyle = .overFullScreen
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        rootViewController?.present(profitabilityTooltip, animated: false)
    }

    func gotoTransactions(with fund: FundRepresentable) {
        let coordinator = dependencies.external.fundTransactionsCoordinator()
        coordinator
            .set(fund)
            .start()
        append(child: coordinator)
    }
}

private extension DefaultFundsHomeCoordinator {
    struct Dependency: FundsHomeDependenciesResolver {
        let dependencies: FundsHomeExternalDependenciesResolver
        let coordinator: FundsHomeCoordinator
        let dataBinding = DataBindingObject()

        var external: FundsHomeExternalDependenciesResolver {
            return dependencies
        }

        func resolve() -> FundsHomeCoordinator {
            return coordinator
        }

        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
