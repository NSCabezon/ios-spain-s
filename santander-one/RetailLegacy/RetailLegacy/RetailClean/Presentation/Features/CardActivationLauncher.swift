protocol CardActivationLauncher: OperativeLauncher {
    func activateCard(_ card: Card?, launchedFrom: OperativeLaunchedFrom, delegate: OperativeLauncherDelegate)
}

extension CardActivationLauncher {    
    func activateCard(_ card: Card?, launchedFrom: OperativeLaunchedFrom, delegate: OperativeLauncherDelegate) {
        let operative = ActivateCardOperative(dependencies: delegate.dependencies)
        let operativeData = ActivateCardOperativeData(card: card, launchedFrom: launchedFrom)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: card == nil, container: container, delegate: delegate.operativeDelegate)
    }
}
