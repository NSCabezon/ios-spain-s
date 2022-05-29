protocol CardCESSignUpLauncher {
    func signupCesCard(_ product: Card?, delegate: OperativeLauncherDelegate)
}

extension CardCESSignUpLauncher {
    
    func signupCesCard(_ product: Card?, delegate: OperativeLauncherDelegate) {
        let operative = SignUpCesCardOperative(dependencies: delegate.dependencies)
        let operativeData = SignUpCesOperativeData(card: product)
        operativeData.tooltipMessage = "ces_tooltip_info"
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: product == nil, container: container, delegate: delegate.operativeDelegate)
    }
}
