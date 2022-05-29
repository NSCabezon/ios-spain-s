//
//  DefaultBasicInfoModuleCoordinator.swift
//  PersonalArea
//
//  Created by alvola on 09/03/2020.
//

import UI
import CoreFoundationLib
import SANLegacyLibrary

final class DefaultBasicInfoModuleCoordinator: ModuleCoordinator {
    
    public weak var navigationController: UINavigationController?
    private lazy var dependencies = Dependency(external: externalDependencies)
    private lazy var legacyDependenciesEngine = DependenciesDefault(father: dependencies.external.resolve())
    private let externalDependencies: PersonalAreaBasicInfoExternalDependenciesResolver
    var childCoordinators: [Coordinator] = []
    var onFinish: (() -> Void)?
    
    init(dependenciesResolver: PersonalAreaBasicInfoExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependenciesResolver
        self.setupDependencies()
    }
    
    public func start() {
        let basicView = legacyDependenciesEngine.resolve(for: BasicInfoViewProtocol.self)
        self.navigationController?.blockingPushViewController(basicView, animated: true)
    }
    
    func end() {
        navigationController?.popViewController(animated: true)
    }
}

extension DefaultBasicInfoModuleCoordinator: PersonalAreaBasicInfoCoordinator {}

private extension DefaultBasicInfoModuleCoordinator {
    struct Dependency: PersonalAreaBasicInfoDependenciesResolver {
        let external: PersonalAreaBasicInfoExternalDependenciesResolver
    }
    
    func setupDependencies() {
        self.legacyDependenciesEngine.register(for: BasicInfoPresenterProtocol.self) { dependenciesResolver in
            let presenter = BasicInfoModulePresenter(dependenciesResolver: dependenciesResolver)
            presenter.moduleCoordinatorNavigator = self.legacyDependenciesEngine.resolve(for: PersonalAreaMainModuleNavigator.self)
            presenter.moduleCoordinator = self
            presenter.dataManager = self.legacyDependenciesEngine.resolve(for: PersonalAreaDataManagerProtocol.self)
            return presenter
        }
        
        self.legacyDependenciesEngine.register(for: BasicInfoViewProtocol.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: BasicInfoPresenterProtocol.self)
            let view = BasicInfoModuleViewController(presenter: presenter)
            presenter.view = view
            return view
        }
    }
}
