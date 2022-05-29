protocol LoanOperativeLauncher: class {
    var dependencies: PresentationComponent { get }
    var errorHandler: GenericPresenterErrorHandler { get }
    var navigator: OperativesNavigatorProtocol { get }
    func changeLinkedAccount(forLoan loan: Loan, withDelegate delegate: OperativeLauncherDelegate)
}

extension LoanOperativeLauncher {
    func changeLinkedAccount(forLoan loan: Loan, withDelegate delegate: OperativeLauncherDelegate) {
        let operative = ChangeLinkedAccountOperative(dependencies: dependencies)
        
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: dependencies) else {
            return
        }
        
        container.saveParameter(parameter: loan)
        operative.start(needsSelection: false, container: container, delegate: delegate.operativeDelegate)

    }
}
