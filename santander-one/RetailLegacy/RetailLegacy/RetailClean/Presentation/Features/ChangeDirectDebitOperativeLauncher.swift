protocol ChangeDirectDebitOperativeLauncher {
    func showChangeDirectDebit(bill: Bill, billDetail: BillDetail, delegate: OperativeLauncherDelegate)
}

extension ChangeDirectDebitOperativeLauncher {
    func showChangeDirectDebit(bill: Bill, billDetail: BillDetail, delegate: OperativeLauncherDelegate) {
        let operative = ChangeDirectDebitOperative(dependencies: delegate.dependencies)
        let operativeData = ChangeDirectDebitOperativeData(bill: bill, billDetail: billDetail)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: false, container: container, delegate: delegate.operativeDelegate)
    }
}
