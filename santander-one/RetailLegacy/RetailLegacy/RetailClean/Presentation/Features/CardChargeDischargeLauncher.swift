protocol CardChargeDischargeLauncher {
    func showCardChargeDischargeCard(_ product: Card?, delegate: OperativeLauncherDelegate)
}

extension CardChargeDischargeLauncher {
    
    func showCardChargeDischargeCard(_ product: Card?, delegate: OperativeLauncherDelegate) {
        let operative = ChargeDischargeCardOperative(dependencies: delegate.dependencies)
        let operativeData = ChargeDischargeCardOperativeData(card: product)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: product == nil, container: container, delegate: delegate.operativeDelegate)
    }
}
