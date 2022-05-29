//
//  DigitalProfileModuleCoordinator.swift
//  PersonalArea
//
//  Created by alvola on 06/03/2020.
//

import UI
import CoreFoundationLib
import SANLegacyLibrary

final class DefaultDigitalProfileModuleCoordinator: ModuleCoordinator {

    public weak var navigationController: UINavigationController?
    private lazy var dependencies = Dependency(external: externalDependencies)
    private lazy var legacyDependenciesEngine = DependenciesDefault(father: dependencies.external.resolve())
    private let externalDependencies: PersonalAreaDigitalProfileExternalDependenciesResolver
    
    var childCoordinators: [Coordinator] = []
    var onFinish: (() -> Void)?
    
    public init(dependenciesResolver: PersonalAreaDigitalProfileExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependenciesResolver
        self.setupDependencies()
    }
    
    public func start() {
        let digProfView = legacyDependenciesEngine.resolve(for: DigitalProfileViewProtocol.self)
        self.navigationController?.blockingPushViewController(digProfView, animated: true)
    }
    
    func end() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupDependencies() {
        self.legacyDependenciesEngine.register(for: DigitalProfilePresenterProtocol.self) { dependenciesResolver in
            let presenter = DigitalProfilePresenter(dependenciesResolver: dependenciesResolver)
            presenter.moduleCoordinatorNavigator = self.legacyDependenciesEngine.resolve(for: PersonalAreaMainModuleNavigator.self)
            presenter.moduleCoordinator = self
            presenter.dataManager = self.legacyDependenciesEngine.resolve(for: PersonalAreaDataManagerProtocol.self)
            return presenter
        }
        
        self.legacyDependenciesEngine.register(for: DigitalProfileViewProtocol.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: DigitalProfilePresenterProtocol.self)
            let view = DigitalProfileViewController(presenter: presenter)
            presenter.view = view
            return view
        }
        
        self.legacyDependenciesEngine.register(for: DigitalProfileUseCase.self) { dependenciesResolver in
            return DigitalProfileUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.legacyDependenciesEngine.register(for: PersonalAreaDigitalProfileCoordinator.self) { _ in
            return self
        }
    }
}

extension DefaultDigitalProfileModuleCoordinator: PersonalAreaDigitalProfileCoordinator {
    func goToUserBasicInfo() {
        let coordinator = self.dependencies.external.personalAreaBasicInfoCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
    
    func goToConfiguration() {
        let coordinator = self.dependencies.external.personalAreaConfigurationCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
    
    func goToSecurity() {
        let coordinator = self.dependencies.external.personalAreaSecurityCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
}

private extension DefaultDigitalProfileModuleCoordinator {
    struct Dependency: PersonalAreaDigitalProfileDependenciesResolver {
        let external: PersonalAreaDigitalProfileExternalDependenciesResolver
    }
}
