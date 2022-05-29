import CoreFoundationLib
import Transfer
import UIKit

extension TransferHomeNavigator: TransferModuleCoordinatorLauncher {
    var navigatorProvider: NavigatorProvider {
        return presenterProvider.navigatorProvider
    }
    
    var transferDependenciesEngine: DependenciesResolver & DependenciesInjector {
        return presenterProvider.dependenciesEngine
    }
    
    var navigationController: UINavigationController {
        return (drawer.currentRootViewController as? UINavigationController) ?? UINavigationController()
    }
    
    var transferExternalResolver: TransferExternalDependenciesResolver {
        return presenterProvider.navigatorProvider.legacyExternalDependenciesResolver
    }
}
