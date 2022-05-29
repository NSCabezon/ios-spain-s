//
//  LoanDetailCoordinator.swift
//  Alamofire
//
//  Created by Juan Jose Acosta on 23/2/22.
//
import UI
import CoreFoundationLib
import Foundation
import CoreDomain

protocol LoanDetailCoordinator: BindableCoordinator {
    func share( _ shareable: Shareable, type: ShareType)
    func didSelectMenu()
}

final class DefaultLoanDetailCoordinator: LoanDetailCoordinator {
    var onFinish: (() -> Void)?
    weak var navigationController: UINavigationController?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: LoanDetailExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: LoanDetailExternalDependenciesResolver,
                navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
    
    func share( _ shareable: Shareable, type: ShareType) {
        let coordinator: ShareCoordinator = dependencies.external.resolve()
        coordinator
            .set(shareable)
            .set(type)
            .start()
        append(child: coordinator)
    }
    
    func didSelectMenu() {
        let coordinator = dependencies.external.privateMenuCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
}

extension DefaultLoanDetailCoordinator {
    func start() {
        guard dataBinding.contains(LoanRepresentable.self) else { return }
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
}

private extension DefaultLoanDetailCoordinator {
    struct Dependency: LoanDetailDependenciesResolver {
        let dependencies: LoanDetailExternalDependenciesResolver
        let coordinator: LoanDetailCoordinator
        let dataBinding = DataBindingObject()
        
        var external: LoanDetailExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> LoanDetailCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
