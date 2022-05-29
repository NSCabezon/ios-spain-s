import QuickSetup
import CoreFoundationLib

extension DefaultFeatureFlagsCoordinator: DefaultModuleLauncher {
    public convenience init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController) {
        self.init(dependencies: FeatureFlagsDependenciesInitializer(dependencies: DependenciesDefault(father: dependenciesResolver), navigationController: navigationController))
    }
}
