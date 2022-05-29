import Foundation

protocol CancelDirectBillingLauncher {
    func showCancelDirectBilling(bill: Bill, billDetail: BillDetail, delegate: OperativeLauncherDelegate)
}

extension CancelDirectBillingLauncher {
    func showCancelDirectBilling(bill: Bill, billDetail: BillDetail, delegate: OperativeLauncherDelegate) {
        let operative = CancelDirectBillingOperative(dependencies: delegate.dependencies)
        let operativeData = CancelDirectBillingOperativeData(bill: bill, billDetail: billDetail)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: false, container: container, delegate: delegate.operativeDelegate)
    }
}
