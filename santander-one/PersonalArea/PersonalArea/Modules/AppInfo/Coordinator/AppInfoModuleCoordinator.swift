//
//  AppInfoModuleCoordinator.swift
//  PersonalArea
//
//  Created by alvola on 21/04/2020.
//

import UI
import CoreFoundationLib
import SANLegacyLibrary

final class AppInfoModuleCoordinator: ModuleCoordinator {

    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let appInfoView = dependenciesEngine.resolve(for: AppInfoViewProtocol.self)
        self.navigationController?.blockingPushViewController(appInfoView, animated: true)
    }
    
    func end() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupDependencies() {
        
        self.dependenciesEngine.register(for: AppInfoDataSourceProtocol.self) { dependenciesResolver in
            return AppInfoDataSource(dependenciesEngine: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: AppInfoPresenterProtocol.self) { dependenciesResolver in
            let presenter = AppInfoModulePresenter(dependenciesResolver: dependenciesResolver)
            presenter.moduleCoordinatorNavigator = self.dependenciesEngine.resolve(for: PersonalAreaMainModuleNavigator.self)
            presenter.moduleCoordinator = self
            return presenter
        }
        
        self.dependenciesEngine.register(for: AppInfoViewProtocol.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: AppInfoPresenterProtocol.self)
            let view = AppInfoModuleViewController(presenter: presenter)
            presenter.view = view
            return view
        }
    }
}
