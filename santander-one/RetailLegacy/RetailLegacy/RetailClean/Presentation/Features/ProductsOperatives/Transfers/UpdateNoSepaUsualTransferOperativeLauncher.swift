protocol UpdateNoSepaUsualTransferOperativeLauncher {
    func showUpdateNoSepaFavourite(_ favourite: Favourite, noSepaDetail: NoSepaPayeeDetail, delegate: OperativeLauncherDelegate)
}

extension UpdateNoSepaUsualTransferOperativeLauncher {
    func showUpdateNoSepaFavourite(_ favourite: Favourite, noSepaDetail: NoSepaPayeeDetail, delegate: OperativeLauncherDelegate) {
        let operative = UpdateNoSepaUsualTransferOperative(dependencies: delegate.dependencies)
        let operativeData = UpdateNoSepaUsualTransferOperativeData(favourite: favourite, noSepaDetail: noSepaDetail)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: false, container: container, delegate: delegate.operativeDelegate)
    }
}
