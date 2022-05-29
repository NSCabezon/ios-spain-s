//
//  LoginRememberedCoordinator.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/3/20.
//

import UI
import CoreFoundationLib
import Ecommerce

protocol LoginRememberedCoordinatorProtocol {
    func showEcommerce()
}

final class LoginRememberedCoordinator: ModuleCoordinator {
    weak var navigationController: UINavigationController?
    let dependenciesEngine: DependenciesDefault
    private let ecommerceCoordinator: EcommerceModuleCoordinator
    private lazy var loginLayerManager: LoginLayerManager = {
        return LoginLayerManager(dependenciesResolver: self.dependenciesEngine)
    }()
    
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        self.ecommerceCoordinator = EcommerceModuleCoordinator(
            dependenciesResolver: dependenciesResolver,
            navigationController: navigationController ?? UINavigationController()
        )
        self.setupDependencies()
    }
    
    func start() {
        let controller = self.dependenciesEngine.resolve(for: LoginRememberedViewController.self)
        self.navigationController?.viewControllers = [controller]
    }
}

private extension LoginRememberedCoordinator {
    func setupDependencies() {
        let presenter = LoginRememberedPresenter(dependenciesResolver: self.dependenciesEngine)
        self.dependenciesEngine.register(for: LoginPresenterLayerProtocol.self) { _ in
            return presenter
        }
        self.dependenciesEngine.register(for: LoginRememberedPresenterProtocol.self) { _ in
            return presenter
        }
        self.dependenciesEngine.register(for: LoginRememberedViewController.self) { resolver in
            var presenter = resolver.resolve(for: LoginRememberedPresenterProtocol.self)
            let controller = LoginRememberedViewController(
                nibName: "LoginRememberedView",
                bundle: .module,
                dependenciesResolver: resolver,
                presenter: presenter)
            presenter.view = controller
            presenter.loginManager = self.loginLayerManager
            return controller
        }
        self.dependenciesEngine.register(for: LoginRememberedCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: LoadRememberedLoginDataUseCase.self) { resolver in
            return LoadRememberedLoginDataUseCase(dependenciesResolver: resolver)
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
        self.dependenciesEngine.register(for: GetUserPrefEntityUseCase.self) { resolver in
            return GetUserPrefEntityUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: Device.self) { _ in
            return IOSDevice()
        }
        self.dependenciesEngine.register(for: LoginRememberParamTracker.self) { resolver in
            return LoginRememberParamTracker(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: SetTouchIdLoginDataUseCase.self) { resolver in
            return SetTouchIdLoginDataUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetTouchIdLoginDataUseCase.self) { resolver in
            return GetTouchIdLoginDataUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetOtpPushNotificationUseCase.self) { resolver in
            return GetOtpPushNotificationUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: RemovePersistedUserUseCase.self) { resolver in
            return RemovePersistedUserUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: SetWidgetAccessUseCase.self) { resolver in
            return SetWidgetAccessUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: IsEcommerceEnabledUseCase.self) { resolver in
            return IsEcommerceEnabledUseCase(dependenciesResolver: resolver)
        }
        self.registerLoginProcessDepencencies()
        self.registerSessionDependencies()
        self.registerPullOfferDependencies()
        self.registerEnvironmentDependencies()
    }
}

extension LoginRememberedCoordinator: LoginRememberedCoordinatorProtocol {
    func showEcommerce() {
        ecommerceCoordinator.start(EcommerceModuleCoordinator.EcommerceSection.mainDefault)
    }
}

extension LoginRememberedCoordinator: LoginProcessResolverCapable { }
extension LoginRememberedCoordinator: LoginSessionResolverCapable {}
extension LoginRememberedCoordinator: LoginPullOfferResolverCapable {}
extension LoginRememberedCoordinator: LoginChangeEnvironmentResolverCapable {}
