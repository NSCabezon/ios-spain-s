import Funds
import CoreFoundationLib

final class FundsHomeCoordinatorNavigator: ModuleCoordinatorNavigator {
    var operativeCoordinatorLauncher: OperativeCoordinatorLauncher {
        return self.dependenciesEngine.resolve()
    }
}

extension FundsHomeCoordinatorNavigator: FundOperativeLauncher {}
