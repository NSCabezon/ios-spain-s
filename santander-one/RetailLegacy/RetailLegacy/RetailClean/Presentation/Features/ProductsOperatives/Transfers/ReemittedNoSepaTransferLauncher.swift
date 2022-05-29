protocol ReemittedNoSepaTransferLauncher {
    func showReemittedNoSepaTransfer(transferDetail: BaseNoSepaPayeeDetailProtocol, account: Account?, delegate: OperativeLauncherDelegate, launchedFrom origin: ReemitedNoSepaTransferOrigin, accountType: String?)
}

enum ReemitedNoSepaTransferOrigin {
    case emittedTransfer, favorite
}

extension ReemittedNoSepaTransferLauncher {
    func showReemittedNoSepaTransfer(transferDetail: BaseNoSepaPayeeDetailProtocol, account: Account?, delegate: OperativeLauncherDelegate, launchedFrom origin: ReemitedNoSepaTransferOrigin, accountType: String?) {
        let operative = ReemittedNoSepaTransferOperative(dependencies: delegate.dependencies)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        let operativeData = ReemittedNoSepaTransferOperativeData(transferDetail: transferDetail, account: account, operativeOrigin: origin, accountType: accountType)
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: account == nil, container: container, delegate: delegate.operativeDelegate)
    }
}
