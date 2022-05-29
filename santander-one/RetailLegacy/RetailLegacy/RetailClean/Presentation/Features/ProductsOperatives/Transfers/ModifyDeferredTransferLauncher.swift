//

import Foundation

protocol ModifyDeferredTransferLauncher {
    func showModifyDeferredTransfer(account: Account, transfer: TransferScheduled, scheduledTransferDetail: ScheduledTransferDetail, delegate: OperativeLauncherDelegate)
}

extension ModifyDeferredTransferLauncher {
    
    func showModifyDeferredTransfer(account: Account, transfer: TransferScheduled, scheduledTransferDetail: ScheduledTransferDetail, delegate: OperativeLauncherDelegate) {
        let operative = ModifyDeferredTransferOperative(dependencies: delegate.dependencies)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        let operativeData = ModifyDeferredTransferOperativeData(transferScheduled: transfer, scheduledTransferDetail: scheduledTransferDetail, account: account)
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: false, container: container, delegate: delegate.operativeDelegate)
    }
}
