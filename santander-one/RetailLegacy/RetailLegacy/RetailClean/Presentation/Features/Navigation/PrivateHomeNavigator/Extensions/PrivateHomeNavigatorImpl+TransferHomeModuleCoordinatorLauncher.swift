import CoreFoundationLib
import Transfer

extension PrivateHomeNavigatorImpl: TransferModuleCoordinatorLauncher {
    var navigationController: UINavigationController {
        return (drawer.currentRootViewController as? UINavigationController) ?? UINavigationController()
    }
    
    var navigatorProvider: NavigatorProvider {
        return presenterProvider.navigatorProvider
    }
    
    var transferDependenciesEngine: DependenciesResolver & DependenciesInjector {
        return presenterProvider.dependenciesEngine
    }

    var transferExternalResolver: TransferExternalDependenciesResolver {
        return presenterProvider.navigatorProvider.legacyExternalDependenciesResolver
    }
}
