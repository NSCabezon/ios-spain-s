//
//  SecureDeviceTutorialCoordinator.swift
//  PersonalArea
//
//  Created by Carlos Monfort Gómez on 22/01/2020.
//

import CoreFoundationLib
import SANLegacyLibrary
import UI

final class SecureDeviceTutorialCoordinator: ModuleCoordinator {

    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let deviceAliasView = dependenciesEngine.resolve(for: SecureDeviceTutorialViewProtocol.self)
        self.navigationController?.blockingPushViewController(deviceAliasView, animated: true)
    }
    
    func end() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: SecureDeviceTutorialPresenterProtocol.self) {
            let presenter = SecureDeviceTutorialPresenter(dependenciesResolver: $0)
            presenter.moduleCoordinator = self
            return presenter
        }
        
        self.dependenciesEngine.register(for: SecureDeviceTutorialViewProtocol.self) {
            var presenter = $0.resolve(for: SecureDeviceTutorialPresenterProtocol.self)
            let view = SecureDeviceTutorialViewController(presenter: presenter)
            presenter.view = view
            return view
        }
        self.dependenciesEngine.register(for: GetPullOffersUseCase.self) { dependenciesResolver in
            return GetPullOffersUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
}
