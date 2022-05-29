protocol CancelTransferLauncher {
    func startCancelTransferOperative(transferScheduled: TransferScheduled?, account: Account?, scheduledTransferDetail: ScheduledTransferDetail?, delegate: OperativeLauncherDelegate?)
}

extension CancelTransferLauncher {
    func startCancelTransferOperative(transferScheduled: TransferScheduled?, account: Account?, scheduledTransferDetail: ScheduledTransferDetail?, delegate: OperativeLauncherDelegate?) {
        guard let delegate = delegate, let transferScheduled = transferScheduled, let account = account else { return }
        let operative = CancelTransferOperative(dependencies: delegate.dependencies)
        let operativeData = CancelTransferOperativeData(transferScheduled: transferScheduled, scheduledTransferDetail: scheduledTransferDetail, account: account)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: false, container: container, delegate: delegate.operativeDelegate)
    }
}
