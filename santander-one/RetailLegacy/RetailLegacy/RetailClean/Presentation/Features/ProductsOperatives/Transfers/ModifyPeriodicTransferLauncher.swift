//

import Foundation

protocol ModifyPeriodicTransferLauncher {
    func showModifyPeriodicTransfer(account: Account, transfer: TransferScheduled, scheduledTransferDetail: ScheduledTransferDetail, delegate: OperativeLauncherDelegate)
}

extension ModifyPeriodicTransferLauncher {
    
    func showModifyPeriodicTransfer(account: Account, transfer: TransferScheduled, scheduledTransferDetail: ScheduledTransferDetail, delegate: OperativeLauncherDelegate) {
        let operative = ModifyPeriodicTransferOperative(dependencies: delegate.dependencies)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        let operativeData = ModifyPeriodicTransferOperativeData(transferScheduled: transfer, scheduledTransferDetail: scheduledTransferDetail, account: account)
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: false, container: container, delegate: delegate.operativeDelegate)
    }
}
