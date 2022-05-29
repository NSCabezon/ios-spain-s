import Transfer
import UIKit
import CoreFoundationLib

extension TransfersHomeCoordinatorNavigator: TransferModuleCoordinatorLauncher {
    var navigationController: UINavigationController {
        return (drawer?.currentRootViewController as? UINavigationController) ?? UINavigationController()
    }
    
    var transferDependenciesEngine: DependenciesResolver & DependenciesInjector {
        return dependenciesEngine
    }
    
    var transferExternalResolver: TransferExternalDependenciesResolver {
        return dependencies.navigatorProvider.legacyExternalDependenciesResolver
    }
}
