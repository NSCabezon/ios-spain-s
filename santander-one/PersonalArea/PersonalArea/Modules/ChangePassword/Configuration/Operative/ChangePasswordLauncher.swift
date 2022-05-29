import Foundation
import Operative
import CoreFoundationLib

public protocol ChangePasswordLauncher: OperativeContainerLauncher {
    func goToChangePassword(handler: OperativeLauncherHandler)
}

public extension ChangePasswordLauncher {
    func goToChangePassword(handler: OperativeLauncherHandler) {
        let dependenciesEngine = DependenciesDefault(father: handler.dependenciesResolver)
        self.setupDependencies(in: dependenciesEngine, handler: handler)
        let operative = ChangePasswordOperative(dependencies: dependenciesEngine)
        self.go(to: operative, handler: handler)
    }    
}

private extension ChangePasswordLauncher {
    func setupDependencies(in dependenciesInjector: DependenciesInjector, handler: OperativeLauncherHandler) {
        dependenciesInjector.register(for: ChangePasswordFinishingCoordinatorProtocol.self) { _ in
            return ChangePasswordFinishingCoordinator(navigatorController: handler.operativeNavigationController)
        }
        dependenciesInjector.register(for: ChangePasswordConfiguration.self) { _ in
            return ChangePasswordConfiguration(message: "keyChange_text_about", maxLength: 8, minLength: 8, keyboardType: .numberPad)
        }
    }
}
