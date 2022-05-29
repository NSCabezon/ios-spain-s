protocol UpdateUsualTransferOperativeLauncher {
    func showUpdateUsualTransfer(favourite: Favourite, delegate: OperativeLauncherDelegate)
}

extension UpdateUsualTransferOperativeLauncher {
    func showUpdateUsualTransfer(favourite: Favourite, delegate: OperativeLauncherDelegate) {
        let operative = UpdateUsualTransferOperative(dependencies: delegate.dependencies)
        let operativeData = UpdateUsualTransferOperativeData(favourite: favourite)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: false, container: container, delegate: delegate.operativeDelegate)
    }
}
