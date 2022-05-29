import Foundation
import CoreFoundationLib

protocol LandingPushLauncherNavigatorProtocol {
    var drawer: BaseMenuViewController { get }
    var presenterProvider: PresenterProvider { get }
    
    func launchLandingPush(cardTransactionInfo: CardTransactionPush?, cardAlertInfo: CardAlertPush?)
    func genericLaunchLandingPush(accountTransactionInfo: AccountLandingPushData)
}

extension LandingPushLauncherNavigatorProtocol {
    func launchLandingPush(cardTransactionInfo: CardTransactionPush?, cardAlertInfo: CardAlertPush?) {
        let presenterView = presenterProvider.landingPushPresenter(cardTransactionInfo: cardTransactionInfo, cardAlertInfo: cardAlertInfo)
        presenterView.view.modalPresentationStyle = .fullScreen
        drawer.currentRootViewController?.present(presenterView.view, animated: true, completion: nil)
    }
    
    func genericLaunchLandingPush(accountTransactionInfo: AccountLandingPushData) {
        let presenterView = presenterProvider.genericLandingPushPresenter(accountTransactionInfo: accountTransactionInfo)
        presenterView.view.modalPresentationStyle = .fullScreen
        drawer.currentRootViewController?.present(presenterView.view, animated: true, completion: nil)
    }
}

class LandingPushLauncherNavigator {
    let drawer: BaseMenuViewController
    let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.drawer = drawer
        self.presenterProvider = presenterProvider
    }
}

extension LandingPushLauncherNavigator: LandingPushLauncherNavigatorProtocol {}
