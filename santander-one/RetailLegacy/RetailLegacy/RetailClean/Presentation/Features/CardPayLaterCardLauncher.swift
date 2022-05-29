protocol CardPayLaterCardLauncher {
    func showPayLaterCard(card: Card?, delegate: OperativeLauncherDelegate)
}

extension CardPayLaterCardLauncher {    
    func showPayLaterCard(card: Card?, delegate: OperativeLauncherDelegate) {
        let operative = PayLaterCardOperative(dependencies: delegate.dependencies)
        let operativeData = PayLaterCardOperativeData(card: card)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: card == nil, container: container, delegate: delegate.operativeDelegate)
    }
}
