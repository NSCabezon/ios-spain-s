import CoreFoundationLib

protocol CardCVVQueryCardLauncher {
    func showCVVQueryCard(_ product: Card?, delegate: OperativeLauncherDelegate)
}

extension CardCVVQueryCardLauncher {
    
    func showCVVQueryCard(_ product: Card?, delegate: OperativeLauncherDelegate) {
        let operative = CVVQueryCardOperative(dependencies: delegate.dependencies)
        let operativeData = CVVQueryCardOperativeData(card: product)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: product == nil, container: container, delegate: delegate.operativeDelegate)
    }
}
