//
//  SecurityModuleCoordinator.swift
//  PersonalArea
//
//  Created by alvola on 09/03/2020.
//

import UI
import CoreFoundationLib
import SANLegacyLibrary
import Operative

final class DefaultSecurityModuleCoordinator: BindableCoordinator {
    public weak var navigationController: UINavigationController?
    private lazy var dependencies = Dependency(external: externalDependencies)
    private lazy var legacyDependenciesEngine = DependenciesDefault(father: dependencies.external.resolve())
    private let externalDependencies: PersonalAreaSecurityExternalDependenciesResolver
    
    var childCoordinators: [Coordinator] = []
    var onFinish: (() -> Void)?
    var dataBinding: DataBinding {
        dependencies.resolve()
    }
    
    init(dependenciesResolver: PersonalAreaSecurityExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependenciesResolver
        self.setupDependencies()
    }
    
    public func start() {
        guard let otpPushDevice: OTPPushDeviceEntity = dataBinding.get() else { return defaultStart() }
        goToSecureDevice(device: otpPushDevice)
    }
    
    func defaultStart() {
        let secView = legacyDependenciesEngine.resolve(for: SecurityViewProtocol.self)
        self.navigationController?.blockingPushViewController(secView, animated: true)
    }
    
    private func setupDependencies() {
        self.legacyDependenciesEngine.register(for: LastAccessInfoManagerProtocol.self) { _ in
            return LastAccessInfoManager(dependenciesEngine: self.legacyDependenciesEngine)
        }
        
        self.legacyDependenciesEngine.register(for: SecurityPresenterProtocol.self) { dependenciesResolver in
            let presenter = SecurityModulePresenter(dependenciesResolver: dependenciesResolver)
            presenter.moduleCoordinator = self
            presenter.dataManager = self.legacyDependenciesEngine.resolve(for: PersonalAreaDataManagerProtocol.self)
            return presenter
        }
        
        self.legacyDependenciesEngine.register(for: SecurityViewProtocol.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: SecurityPresenterProtocol.self)
            let view = SecurityModuleViewController(
                dependenciesResolver: dependenciesResolver,
                presenter: presenter
            )
            presenter.view = view
            return view
        }
        self.legacyDependenciesEngine.register(for: LocationPermission.self) { dependenciesResolver in
            return LocationPermission(dependenciesResolver: dependenciesResolver)
        }
    }
}

extension DefaultSecurityModuleCoordinator {
    func goToSecurityCustomAction() {
        let coordinator = dependencies.external.personalAreaSecurityCustomActionCoordinator()
        coordinator.start()
    }
}

extension DefaultSecurityModuleCoordinator: SecurityModuleNavigator {
    func end() { navigationController?.popViewController(animated: true) }
    func goToSecureDevice(device: OTPPushDeviceEntity?) {
        var coordinator: ModuleCoordinator
        if let device = device {
            let configuration = SecureDeviceAliasConfiguration(secureDevice: device)
            legacyDependenciesEngine.register(for: SecureDeviceAliasConfiguration.self) { _ in
                return configuration
            }
            coordinator = SecureDeviceAliasCoordinator(dependenciesResolver: legacyDependenciesEngine,
                                                       navigationController: navigationController)
        } else {
            coordinator = SecureDeviceTutorialCoordinator(dependenciesResolver: legacyDependenciesEngine,
                                                          navigationController: navigationController)
        }
        coordinator.start()
    }
    
    func goToChangePassword() {
        let personalAreaCoordinator = legacyDependenciesEngine.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
        personalAreaCoordinator.goToChangePassword()
    }
    
    func goToSignature() {
        let personalAreaCoordinator = legacyDependenciesEngine.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
        personalAreaCoordinator.didSelectMultichannelSignature()
    }
    
    func goToOperabilityChange() {
        goToOperabilityChange(handler: self)
    }
}

extension DefaultSecurityModuleCoordinator: OperabilityChangeLauncher {}

extension DefaultSecurityModuleCoordinator: OperativeLauncherHandler {
    
    public var dependenciesResolver: DependenciesResolver {
        return self.legacyDependenciesEngine
    }
    
    public var operativeNavigationController: UINavigationController? {
        return navigationController
    }
    
    public func showOperativeLoading(completion: @escaping () -> Void) {
        completion()
    }
    
    public func hideOperativeLoading(completion: @escaping () -> Void) {
        completion()
    }
    
    public func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        let delegate = self.legacyDependenciesEngine.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
        delegate.showAlertDialog(acceptTitle: localized("generic_button_accept"), cancelTitle: nil, title: localized(keyTitle ?? ""), body: localized(keyDesc ?? ""), acceptAction: nil, cancelAction: nil)
        completion?()
    }
}

extension DefaultSecurityModuleCoordinator: PersonalAreaSecurityCoordinator {}

private extension DefaultSecurityModuleCoordinator {
    struct Dependency: PersonalAreaSecurityDependenciesResolver {
        let external: PersonalAreaSecurityExternalDependenciesResolver
        let dataBinding: DataBinding = DataBindingObject()
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}

protocol SecurityModuleNavigator: AnyObject {
    func end()
    func goToSecureDevice(device: OTPPushDeviceEntity?)
    func goToChangePassword()
    func goToSignature()
}
