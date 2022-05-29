import CoreFoundationLib

class FundOperativesPresenterProvider {
    
    var fundSubscriptionPresenter: FundSubscriptionPresenter {
        return FundSubscriptionPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var fundSubscriptionConfirmationPresenter: FundSubscriptionConfirmationPresenter {
        return FundSubscriptionConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.defaultMifidLauncherNavigator)
    }
    
    var fundTransferDestinationSelectionPresenter: FundTransferDestinationSelectionPresenter {
        return FundTransferDestinationSelectionPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var fundTransferTypeSelectionPresenter: FundTransferTypeSelectionPresenter {
        return FundTransferTypeSelectionPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var fundTransferConfirmation: FundTransferConfirmationPresenter {
        return FundTransferConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.defaultMifidLauncherNavigator)
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
