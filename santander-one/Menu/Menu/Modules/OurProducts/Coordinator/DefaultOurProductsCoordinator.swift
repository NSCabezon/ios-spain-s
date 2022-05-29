//
//  OurProductsCoordinator.swift
//  Menu
//
//  Created by alvola on 29/04/2020.
//

import CoreFoundationLib
import UI

public protocol OurProductsCoordinatorProtocol: AnyObject {
    func close()
    func showDialog()
}

public final class DefaultOurProductsCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private lazy var dependencies = Dependency(dependencies: externalDependencies)
    private lazy var dependenciesEngine = DependenciesDefault(father: dependencies.external.resolve())
    private let externalDependencies: OurProductsExternalDependenciesResolver
    
    public var childCoordinators: [Coordinator] = []
    lazy var dataBinding: DataBinding = dependencies.resolve()
    public var onFinish: (() -> Void)?
    
    init(dependenciesResolver: OurProductsExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependenciesResolver
        self.setupDependencies()
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: OurProductsPresenterProtocol.self) { dependenciesResolver in
            return OurProductsPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: OurProductsViewProtocol.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: OurProductsPresenterProtocol.self)
            let viewController = OurProductsViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        
        self.dependenciesEngine.register(for: LoadPublicProductsUseCase.self) { dependenciesResolver in
            return LoadPublicProductsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: OurProductsCoordinatorProtocol.self) { _ in
            return self
        }
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: OurProductsViewProtocol.self)
        if let viewControllers = self.navigationController?.viewControllers, viewControllers.count > 1 {
            self.navigationController?.popToRootViewController(animated: false)
        }
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
}

extension DefaultOurProductsCoordinator: OurProductsCoordinator {
    
}

extension DefaultOurProductsCoordinator: OurProductsCoordinatorProtocol {
    public func close() {
        navigationController?.popViewController(animated: true)
    }
    
    public func showDialog() {
        let coordinatorDelegate = self.dependenciesEngine.resolve(for: PublicMenuCoordinatorDelegate.self)
        coordinatorDelegate.showAlertDialog(
            acceptTitle: localized("generic_button_accept"),
            cancelTitle: nil,
            title: localized("generic_error_alert_title"),
            body: localized("generic_error_alert_text"), acceptAction: { [weak self] in
            self?.close()
        }, cancelAction: nil)
    }
}

private extension DefaultOurProductsCoordinator {
    struct Dependency: OurProductsDependenciesResolver {
        let dependencies: OurProductsExternalDependenciesResolver
        let dataBinding: DataBinding = DataBindingObject()
        
        var external: OurProductsExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
