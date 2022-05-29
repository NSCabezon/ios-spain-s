protocol CreateUsualTransferOperativeLauncher {
    func showCreateUsualTransfer(delegate: OperativeLauncherDelegate)
}

extension CreateUsualTransferOperativeLauncher {
    func showCreateUsualTransfer(delegate: OperativeLauncherDelegate) {
        let operative = CreateUsualTransferOperative(dependencies: delegate.dependencies)
        let operativeData = CreateUsualTransferOperativeData()
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: false, container: container, delegate: delegate.operativeDelegate)
    }
}
