import UIKit
import CoreFoundationLib

final class OnboardingWelcomePresenter: BaseOnboardingPresenter<OnboardingWelcomeViewController, OnboardingNavigator, OnboardingWelcomePresenterProtocol> {
    override func loadViewData() {
        super.loadViewData()        
    }

    // MARK: - TrackerScreenProtocol
    
    override var screenId: String? {
        return OnboardingPage().page
    }
}

extension OnboardingWelcomePresenter: OnboardingWelcomePresenterProtocol {
    var getUserName: String? {
        return (onboardingUserData?.userAlias ?? "").isBlank ? onboardingUserData?.userName.camelCasedString : onboardingUserData?.userAlias
    }
    
    func continuePressed() {
        navigator.next()
    }
    
    func changeAliasPressed() {
        navigator.gotoScene(step: .alias)
    }
}
