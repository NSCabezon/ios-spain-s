//
//  LanguageSelectorModuleCoordinator.swift
//  PersonalArea
//
//  Created by alvola on 09/03/2020.
//

import UI
import CoreFoundationLib
import SANLegacyLibrary

final class LanguageSelectorModuleCoordinator: ModuleCoordinator {

    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let languageView = dependenciesEngine.resolve(for: LanguageSelectorViewProtocol.self)
        self.navigationController?.blockingPushViewController(languageView, animated: true)
    }
    
    func end() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: LanguageSelectorPresenterProtocol.self) { dependenciesResolver in
            let presenter = LanguageSelectorPresenter(dependenciesResolver: dependenciesResolver)
            presenter.moduleCoordinator = self
            presenter.dataManager = self.dependenciesEngine.resolve(for: PersonalAreaDataManagerProtocol.self)
            return presenter
        }
        
        self.dependenciesEngine.register(for: LanguageSelectorViewProtocol.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: LanguageSelectorPresenterProtocol.self)
            let view = LanguageSelectorViewController(presenter: presenter)
            presenter.view = view
            return view
        }
    }
}
