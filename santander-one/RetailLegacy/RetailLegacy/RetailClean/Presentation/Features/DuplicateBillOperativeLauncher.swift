protocol DuplicateBillOperativeLauncher {
    func showDuplicateBill(bill: Bill, delegate: OperativeLauncherDelegate)
}

extension DuplicateBillOperativeLauncher {
    func showDuplicateBill(bill: Bill, delegate: OperativeLauncherDelegate) {
        let operative = DuplicateBillOperative(dependencies: delegate.dependencies)
        let operativeData = DuplicateBillOperativeData(bill: bill)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: false, container: container, delegate: delegate.operativeDelegate)
    }
}
