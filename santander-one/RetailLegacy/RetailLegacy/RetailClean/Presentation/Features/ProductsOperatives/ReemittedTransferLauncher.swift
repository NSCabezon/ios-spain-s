protocol ReemittedTransferLauncher {
    func showReemittedTransferLauncher(transferDetail: EmittedTransferDetail, transfer: TransferEmitted, account: Account?, delegate: OperativeLauncherDelegate)
}

extension ReemittedTransferLauncher {
    func showReemittedTransferLauncher(transferDetail: EmittedTransferDetail, transfer: TransferEmitted, account: Account?, delegate: OperativeLauncherDelegate) {
        let operative = ReemittedTransferOperative(dependencies: delegate.dependencies)
        let operativeData = ReemittedTransferOperativeData(transferDetail: transferDetail, transfer: transfer, account: account)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        operativeData.iban = transferDetail.beneficiary
        operativeData.name = transfer.beneficiary
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: account == nil, container: container, delegate: delegate.operativeDelegate)
    }
}
