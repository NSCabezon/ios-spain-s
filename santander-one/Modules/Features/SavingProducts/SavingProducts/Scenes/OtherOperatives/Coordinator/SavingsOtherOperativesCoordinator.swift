//
//  SavingsOtherOperativesCoordinator.swift
//  SavingProducts

import Foundation
import CoreFoundationLib
import UI
import CoreDomain
import OpenCombine
import UIOneComponents

public protocol SavingsOtherOperativesCoordinator: BindableCoordinator {
    func goToSavingsAction(type: SavingProductOptionType)
    func dismiss()
}

// MARK: - SavingsOtherOperativesCoordinator
final class DefaultSavingsOtherOperativesCoordinator: SavingsOtherOperativesCoordinator {
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: SavingsOtherOperativesExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    private var data: SavingProductRepresentable? {
            dataBinding.get().map { $0 }
    }
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()

    public init(dependencies: SavingsOtherOperativesExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultSavingsOtherOperativesCoordinator {
    func start() {
        guard let savingProduct = data else {
            self.dismiss()
            return
        }
        let viewModel: OneProductMoreOptionsViewModelProtocol & DataBindable = dependencies.resolve()
        viewModel.dataBinding.set(savingProduct)
        let controller: OneProductMoreOptionsViewController = dependencies.resolve()
        controller.modalPresentationStyle = .fullScreen
        navigationController?.present(controller, animated: true)
    }

    func goToSavingsAction(type: SavingProductOptionType) {
        let otherOperativesCoordinator = externalDependencies.savingsCustomOptionCoordinator()
        navigationController?.dismiss(animated: true) {
            otherOperativesCoordinator
                .set(type)
                .start()
        }
    }

    func dismiss(_ completion: @escaping () -> ()) {
        navigationController?.dismiss(animated: true, completion: completion)
    }
}

private extension DefaultSavingsOtherOperativesCoordinator {
    struct Dependency: SavingsOtherOperativesDependenciesResolver {
        let dependencies: SavingsOtherOperativesExternalDependenciesResolver
        let coordinator: SavingsOtherOperativesCoordinator
        let dataBinding = DataBindingObject()

        var external: SavingsOtherOperativesExternalDependenciesResolver {
            return dependencies
        }

        func resolve() -> SavingsOtherOperativesCoordinator{
            return coordinator
        }

        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}

