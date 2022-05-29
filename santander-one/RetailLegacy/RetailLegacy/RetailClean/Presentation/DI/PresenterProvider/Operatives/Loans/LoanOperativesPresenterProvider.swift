import CoreFoundationLib

class LoanOperativesPresenterProvider {
    
    var changeLoanAssociatedAccountPresenter: ChangeAssociatedAccountPresenter {
        return ChangeAssociatedAccountPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var changeLinkedAccountConfirmationPresenter: ChangeLinkedAccountConfirmationPresenter {
        return ChangeLinkedAccountConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    let navigatorProvider: NavigatorProvider
    let sessionManager: CoreSessionManager
    let dependencies: PresentationComponent
    
    init(navigatorProvider: NavigatorProvider, sessionManager: CoreSessionManager, dependencies: PresentationComponent) {
        self.navigatorProvider = navigatorProvider
        self.sessionManager = sessionManager
        self.dependencies = dependencies
    }
}
