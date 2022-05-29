protocol CardDirectMoneyLauncher {
    func goToDirectMoneyOperative(card: Card?, launchedFrom: OperativeLaunchedFrom, delegate: OperativeLauncherDelegate)
}

extension CardDirectMoneyLauncher {
    
    func goToDirectMoneyOperative(card: Card?, launchedFrom: OperativeLaunchedFrom, delegate: OperativeLauncherDelegate) {
        let operative = DirectMoneyOperative(dependencies: delegate.dependencies)
        let operativeData = DirectMoneyCardOperativeData(cards: [], card: card, launchedFrom: launchedFrom)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: card == nil, container: container, delegate: delegate.operativeDelegate)
    }    
}
