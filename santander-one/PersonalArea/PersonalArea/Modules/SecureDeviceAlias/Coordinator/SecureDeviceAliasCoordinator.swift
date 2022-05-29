//
//  SecureDeviceAliasCordinator.swift
//  PersonalArea
//
//  Created by Carlos Monfort Gómez on 22/01/2020.
//

import UI
import CoreFoundationLib
import SANLegacyLibrary

class SecureDeviceAliasConfiguration {
    let secureDevice: OTPPushDeviceEntity
    
    init(secureDevice: OTPPushDeviceEntity) {
        self.secureDevice = secureDevice
    }
}

final class SecureDeviceAliasCoordinator: ModuleCoordinator {

    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let deviceAliasView = dependenciesEngine.resolve(for: SecureDeviceAliasViewProtocol.self)
        self.navigationController?.blockingPushViewController(deviceAliasView, animated: true)
    }
    
    func end() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: SecureDeviceAliasPresenterProtocol.self) {
            let presenter = SecureDeviceAliasPresenter(dependenciesResolver: $0)
            presenter.moduleCoordinator = self
            return presenter
        }
        
        self.dependenciesEngine.register(for: SecureDeviceAliasViewProtocol.self) {
            let presenter = $0.resolve(for: SecureDeviceAliasPresenterProtocol.self)
            let view = SecureDeviceAliasViewController(presenter: presenter)
            presenter.view = view
            return view
        }
    }
}
