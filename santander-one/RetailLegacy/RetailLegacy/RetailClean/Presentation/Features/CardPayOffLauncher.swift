protocol CardPayOffLauncher: class {
    func goToPayOff(_ card: Card?, delegate: OperativeLauncherDelegate)
}

extension CardPayOffLauncher {
     func goToPayOff(_ card: Card?, delegate: OperativeLauncherDelegate) {
        let operative = PayOffOperative(dependencies: delegate.dependencies)
        let operativeData = PayOffCardOperativeData(cards: [], card: card)
        guard
            let container = delegate.navigatorOperativeLauncher.appendOperative(operative,
                                                                                dependencies: delegate.dependencies)
            else { return }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: card == nil, container: container, delegate: delegate.operativeDelegate)
    }
}
