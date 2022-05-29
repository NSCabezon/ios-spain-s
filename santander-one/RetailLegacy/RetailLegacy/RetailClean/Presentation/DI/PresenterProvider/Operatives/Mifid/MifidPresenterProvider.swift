import CoreFoundationLib

class MifidPresenterProvider {
    
    var mifid1ComplexStepPresenter: Mifid1ComplexStepPresenter {
        return Mifid1ComplexStepPresenter(dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var mifidMfmComplexStepPresenter: Mifid1MfmStepPresenter {
        return Mifid1MfmStepPresenter(dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    let navigatorProvider: NavigatorProvider
    let sessionManager: CoreSessionManager
    let dependencies: PresentationComponent
    
    init(navigatorProvider: NavigatorProvider, sessionManager: CoreSessionManager, dependencies: PresentationComponent) {
        self.navigatorProvider = navigatorProvider
        self.sessionManager = sessionManager
        self.dependencies = dependencies
    }
    
    func mifid2StepPresenter<P: Mifid2StepPresenter>() -> P {
        return P(withProvider: self)
    }
    
    func advisoryClausesMifidStepPresenter<P: MifidAdvisoryClausesStepPresenter>() -> P {
        return P(withProvider: self)
    }
    
    func mifid1SimplePresenter<P: Mifid1SimpleStepPresenter>() -> P {
        return P(withProvider: self)
    }
    
}
