protocol CardLimitManagementLauncher {
    func goToCardLimitManagementOperative(card: Card?, delegate: OperativeLauncherDelegate)
}

extension CardLimitManagementLauncher {
    
    func goToCardLimitManagementOperative(card: Card?, delegate: OperativeLauncherDelegate) {
        let operative = CardLimitManagementOperative(dependencies: delegate.dependencies)
        let operativeData = CardLimitManagementOperativeData(card: card)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: card == nil, container: container, delegate: delegate.operativeDelegate)
    }
}
