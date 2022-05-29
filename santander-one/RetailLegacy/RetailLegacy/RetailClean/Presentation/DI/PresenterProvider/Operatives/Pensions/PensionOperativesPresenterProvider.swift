import CoreFoundationLib

class PensionOperativesPresenterProvider {
    
    var periodicalContributionAmountPresenter: PeriodicalContributionAmountPresenter {
        return PeriodicalContributionAmountPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var extraordinaryContributionAmountPresenter: ExtraordinaryContributionAmountPresenter {
        return ExtraordinaryContributionAmountPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
        
    var extraordinaryContributionConfrimationPresenter: ExtraordinaryContributionConfirmationPresenter {
        return ExtraordinaryContributionConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.defaultMifidLauncherNavigator)
    }
    
    var contributionQuoteConfigurationPresenter: ContributionQuoteConfigurationPresenter {
        return ContributionQuoteConfigurationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.contributionQuoteConfigurationNavigator)
    }
    
    var quoteConfigurationItemsSelectionPresenter: QuoteConfigurationItemsSelectionPresenter {
        return QuoteConfigurationItemsSelectionPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.quoteConfigurationItemsSelectionNavigator)
    }
    
    var periodicalContributionConfirmationPresenter: PeriodicalContributionConfirmationPresenter {
        return PeriodicalContributionConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
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
