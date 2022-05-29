//
//  UnrememberedLoginCoordinator.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/23/20.
//

import CoreFoundationLib
import UI

public class UnrememberedLoginCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    let dependenciesEngine: DependenciesDefault
    private lazy var loginLayerManager: LoginLayerManager = {
        return LoginLayerManager(dependenciesResolver: self.dependenciesEngine)
    }()
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: UnrememberedLoginViewController.self)
        self.navigationController?.viewControllers = [controller]
    }
    
    private func setupDependencies() {
        let presenter = UnrememberedLoginPresenter(dependenciesResolver: self.dependenciesEngine)
        self.dependenciesEngine.register(for: LoginPresenterLayerProtocol.self) { _ in
            return presenter
        }
        self.dependenciesEngine.register(for: UnrememberedLoginPresenterProtocol.self) { _ in
            return presenter
        }
        self.dependenciesEngine.register(for: UnrememberedLoginViewController.self) { resolver in
            var presenter = resolver.resolve(for: UnrememberedLoginPresenterProtocol.self)
            let controller = UnrememberedLoginViewController(
                nibName: "UnrememberedLoginView",
                bundle: .module,
                dependenciesResolver: resolver,
                presenter: presenter)
            presenter.view = controller
            presenter.loginManager = self.loginLayerManager
            return controller
        }
        
        self.dependenciesEngine.register(for: LocationPermission.self) { resolver in
            return LocationPermission(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: PinPointTrusteerUseCase.self) { resolver in
            return PinPointTrusteerUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetUserFUseCase.self) { resolver in
            return GetUserFUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: SetTouchIdLoginDataUseCase.self) { resolver in
            return SetTouchIdLoginDataUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetUserPrefEntityUseCase.self) { resolver in
            return GetUserPrefEntityUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: Device.self) { _ in
            return IOSDevice()
        }
        self.registerLoginProcessDepencencies()
        self.registerSessionDependencies()
        self.registerPullOfferDependencies()
        self.registerEnvironmentDependencies()
    }
}

extension UnrememberedLoginCoordinator: LoginProcessResolverCapable { }
extension UnrememberedLoginCoordinator: LoginSessionResolverCapable {}
extension UnrememberedLoginCoordinator: LoginPullOfferResolverCapable {}
extension UnrememberedLoginCoordinator: LoginChangeEnvironmentResolverCapable {}
