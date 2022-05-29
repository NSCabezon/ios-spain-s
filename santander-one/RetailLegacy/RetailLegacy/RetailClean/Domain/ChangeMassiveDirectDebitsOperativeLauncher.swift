protocol ChangeMassiveDirectDebitsOperativeLauncher {
    func showChangeMassiveDirectDebits(account: Account?, delegate: OperativeLauncherDelegate)
}

extension ChangeMassiveDirectDebitsOperativeLauncher {
    func showChangeMassiveDirectDebits(account: Account?, delegate: OperativeLauncherDelegate) {
        let operative = ChangeMassiveDirectDebitsOperative(dependencies: delegate.dependencies)
        let operativeData = ChangeMassiveDirectDebitsOperativeData(account: account)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: account == nil, container: container, delegate: delegate.operativeDelegate)
    }
}
