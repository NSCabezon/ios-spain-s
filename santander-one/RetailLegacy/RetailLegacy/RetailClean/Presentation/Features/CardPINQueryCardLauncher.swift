protocol CardPINQueryCardLauncher {
    func showPINQueryCard(_ product: Card?, delegate: OperativeLauncherDelegate)
}

extension CardPINQueryCardLauncher {
    
    func showPINQueryCard(_ product: Card?, delegate: OperativeLauncherDelegate) {
        let operative = PINQueryCardOperative(dependencies: delegate.dependencies)
        let operativeData = PINQueryCardOperativeData(card: product)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: product == nil, container: container, delegate: delegate.operativeDelegate)
    }
}
