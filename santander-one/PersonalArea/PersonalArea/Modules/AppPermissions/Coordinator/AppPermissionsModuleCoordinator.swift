//
//  AppPermissionsModuleCoordinator.swift
//  PersonalArea
//
//  Created by Carlos Gutiérrez Casado on 27/04/2020.
//

import UI
import CoreFoundationLib
import SANLegacyLibrary

final class DefaultAppPermissionsModuleCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private lazy var dependencies = Dependency(external: externalDependencies)
    private lazy var legacyDependenciesEngine = DependenciesDefault(father: dependencies.external.resolve())
    private let externalDependencies: PersonalAreaAppPermissionsExternalDependenciesResolver
    
    var childCoordinators: [Coordinator] = []
    var onFinish: (() -> Void)?
    
    public init(dependenciesResolver: PersonalAreaAppPermissionsExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependenciesResolver
        self.setupDependencies()
    }
    
    func start() {
        let appPermissionsView = legacyDependenciesEngine.resolve(for: AppPermissionsViewProtocol.self)
        self.navigationController?.blockingPushViewController(appPermissionsView, animated: true)
    }
    
    func end() {
        navigationController?.popViewController(animated: true)
    }
}

extension DefaultAppPermissionsModuleCoordinator: PersonalAreaAppPermissionsCoordinator {}

extension DefaultAppPermissionsModuleCoordinator {
    private func setupDependencies() {
        self.legacyDependenciesEngine.register(for: AppPermissionsPresenterProtocol.self) { dependenciesResolver in
            return AppPermissionsPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependenciesEngine.register(for: AppPermissionsPresenterProtocol.self) { dependenciesResolver in
            let presenter = AppPermissionsPresenter(dependenciesResolver: dependenciesResolver)
            presenter.moduleCoordinator = self
            presenter.dataManager = self.legacyDependenciesEngine.resolve(for: PersonalAreaDataManagerProtocol.self)
            return presenter
        }
        
        self.legacyDependenciesEngine.register(for: AppPermissionsViewProtocol.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: AppPermissionsPresenterProtocol.self)
            let view = AppPermissionsViewController(presenter: presenter)
            presenter.view = view
            return view
        }
    }
}

private extension DefaultAppPermissionsModuleCoordinator {
    struct Dependency: PersonalAreaAppPermissionsDependenciesResolver {
        let external: PersonalAreaAppPermissionsExternalDependenciesResolver
    }
}
