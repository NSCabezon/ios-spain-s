//
//  SavingsHomeCoordinator.swift
//  Pods
//
//  Created by Adrian Escriche on 14/2/22.
//
import UI
import CoreFoundationLib
import CoreDomain
import OpenCombine
import UIKit

public protocol SavingsHomeCoordinator: BindableCoordinator {
    func openMenu()
    func goToShareHandler(for shareable: Shareable)
    func goToSavingCustomOption(with savings: Savings, option: SavingProductOptionRepresentable)
    func open(url: String)
    func goToPDF(with data: Data)
    func goToMoreOperatives(_ savingProduct: SavingProductRepresentable)
    func goToSendMoney(with option: SavingProductOptionRepresentable)
}

// MARK: - SavingsCoordinator
final class DefaultSavingsHomeCoordinator: SavingsHomeCoordinator {
    var onFinish: (() -> Void)?
    weak var navigationController: UINavigationController?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: SavingsHomeExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()

    private var subscriptions: [AnyCancellable] = []
    
    public init(dependencies: SavingsHomeExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }

    func goToPDF(with data: Data) {
        let coordinator = dependencies.external.resolveSavingsShowPDFCoordinator()
        coordinator
            .set(data)
            .start()
    }
}

extension DefaultSavingsHomeCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }

    func openMenu() {
        let coordinator = dependencies.external.privateMenuCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
    
    func goToShareHandler(for shareable: Shareable) {
        guard let topController = navigationController?.topViewController else { return }
        let sharedHandler: SharedHandler = dependencies.external.resolve()
        sharedHandler.doShare(for: shareable, in: topController)
    }

    func open(url: String) {
        guard let url = URL(string: url),
                UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

    func goToSavingCustomOption(with saving: Savings, option: SavingProductOptionRepresentable) {
        let coordinator = dependencies.external.savingsCustomOptionCoordinator()
        coordinator
            .set(saving.savings)
            .set(option)
            .set(option.type)
            .start()
        append(child: coordinator)

    }

    func goToMoreOperatives(_ savingProduct: SavingProductRepresentable) {
        let coordinator = dependencies.external.otherOperativesCoordinator()
            coordinator.set(savingProduct).start()
            append(child: coordinator)
    }

    func goToSendMoney(with option: SavingProductOptionRepresentable) {
        let checkNewUseCase: SavingsCheckNewHomeSendMoneyIsEnabledUseCase = dependencies.external.resolve()
        checkNewUseCase
            .fetchEnabled()
            .receive(on: Schedulers.main)
            .sink { [unowned self] isEnabled in
                if isEnabled {
                    self.dependencies.external.savingsOneTransferHomeCoordinator().start()
                } else {
                    self.dependencies.external.savingsSendMoneyCoordinator().start()
                }
            }
            .store(in: &subscriptions)
    }
}

private extension DefaultSavingsHomeCoordinator {
    struct Dependency: SavingsHomeDependenciesResolver {

        let dependencies: SavingsHomeExternalDependenciesResolver
        let coordinator: SavingsHomeCoordinator
        let dataBinding = DataBindingObject()
        
        var external: SavingsHomeExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> SavingsHomeCoordinator {
            return coordinator
        }
    
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
