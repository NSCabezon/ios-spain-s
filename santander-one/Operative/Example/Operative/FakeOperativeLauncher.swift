import Operative
import CoreFoundationLib

protocol FakeOperativeLauncher: OperativeContainerLauncher {
    func showFakeOperative(delegate: OperativeLauncherHandler)
}

extension FakeOperativeLauncher {
    func showFakeOperative(delegate: OperativeLauncherHandler) {
        let operative = FakeOperative(dependenciesResolver: DependenciesDefault(father: delegate.dependenciesResolver))
        let operativeData = FakeOperativeData()
        self.go(to: operative, handler: delegate, operativeData: operativeData)
    }
}
