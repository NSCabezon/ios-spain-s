protocol CardWithdrawalMoneyWithCodeLauncher {
    func showWithdrawMoneyWithCode(_ card: Card?, delegate: OperativeLauncherDelegate)
}

extension CardWithdrawalMoneyWithCodeLauncher {
    func showWithdrawMoneyWithCode(_ card: Card?, delegate: OperativeLauncherDelegate) {
        let operative = WithdrawMoneyWithCodeOperative(dependencies: delegate.dependencies)
        let operativeData = WithdrawalWithCodeOperativeData(card: card)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: card == nil, container: container, delegate: delegate.operativeDelegate)
    }
}
