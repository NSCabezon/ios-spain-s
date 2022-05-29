//
//  TipListCoordinator.swift
//  Menu
//
//  Created by Margaret on 04/08/2020.

import UI
import CoreFoundationLib

public protocol TipListCoordinatorDelegate: AnyObject {
    func didSelectDismiss()
    func didSelectMenu()
    func didSelectOfferNodrawer(_ offer: OfferDTO)
}

public protocol TipListCoordinatorProtocol {
    func goToDetail(config: HomeTipsConfiguration)
}

final class DefaultTipListCoordinator: ModuleCoordinator {
    weak var navigationController: UINavigationController?
    private lazy var dependencies = Dependency(dependencies: externalDependencies)
    private lazy var legacyDependenciesEngine = DependenciesDefault(father: dependencies.external.resolve())
    private let externalDependencies: TipListExternalDependenciesResolver
    
    var childCoordinators: [Coordinator] = []
    lazy var dataBinding: DataBinding = dependencies.resolve()
    var onFinish: (() -> Void)?
    
    init(dependenciesResolver: TipListExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependenciesResolver
        self.setupDependencies()
    }

    func start() {
        self.navigationController?.pushViewController(legacyDependenciesEngine.resolve(for: TipListViewController.self), animated: true)
    }
}

private extension DefaultTipListCoordinator {
    func setupDependencies() {
        self.legacyDependenciesEngine.register(for: TipListViewProtocol.self) { dependenciesResolver  in
            return dependenciesResolver.resolve(for: TipListViewController.self)
        }
        self.legacyDependenciesEngine.register(for: TipListCoordinatorDelegate.self) { dependenciesEngine in
            return dependenciesEngine.resolve()
        }

        self.legacyDependenciesEngine.register(for: TipListViewController.self) { dependenciesResolver in
            var presenter: TipListPresenterProtocol = dependenciesResolver.resolve()
            presenter.coordinatorDelegate = self
            let view = TipListViewController(presenter: presenter)
            presenter.view = view
            return view
        }
    }
}
extension DefaultTipListCoordinator: TipListCoordinatorProtocol {
    func goToDetail(config: HomeTipsConfiguration) {
        self.legacyDependenciesEngine.register(for: HomeTipsConfiguration.self) { _ in
            return config
        }
        self.legacyDependenciesEngine.register(for: TipListPresenterProtocol.self) { dependenciesResolver in
            return TipListPresenter(resolver: dependenciesResolver)
        }
        self.start()
    }

    func close() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension DefaultTipListCoordinator: TipListCoordinatorDelegate {
    func didSelectDismiss() {
        self.navigationController?.popViewController(animated: true)
    }

    func didSelectMenu() {
        var delegate: PublicMenuCoordinatorDelegate { legacyDependenciesEngine.resolve() }
        delegate.toggleSideMenu()
    }

    func didSelectOfferNodrawer(_ offer: OfferDTO) {
        var delegate: PublicMenuCoordinatorDelegate { legacyDependenciesEngine.resolve() }
        delegate.didSelectOfferNodrawer(OfferEntity(offer))
    }
}

extension DefaultTipListCoordinator: TipListCoordinator { }

private extension DefaultTipListCoordinator {
    struct Dependency: TipListDependenciesResolver {
        let dependencies: TipListExternalDependenciesResolver
        let dataBinding: DataBinding = DataBindingObject()
        
        var external: TipListExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
