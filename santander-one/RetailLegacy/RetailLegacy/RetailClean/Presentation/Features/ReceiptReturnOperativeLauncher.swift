protocol ReceiptReturnOperativeLauncher {
    func showReceiptReturn(bill: Bill, billDetail: BillDetail, delegate: OperativeLauncherDelegate)
}

extension ReceiptReturnOperativeLauncher {
    func showReceiptReturn(bill: Bill, billDetail: BillDetail, delegate: OperativeLauncherDelegate) {
        let operative = ReceiptReturnOperative(dependencies: delegate.dependencies)
        let operativeData = ReceiptReturnOperativeData(bill: bill, detailBill: billDetail)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: false, container: container, delegate: delegate.operativeDelegate)
    }
}
