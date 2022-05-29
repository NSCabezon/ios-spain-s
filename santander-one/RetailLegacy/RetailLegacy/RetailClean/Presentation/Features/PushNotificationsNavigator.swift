// ------------
import CoreFoundationLib

protocol PushNotificationsNavigatorProtocol: MenuNavigator {
    var presenterProvider: PresenterProvider { get }
    var drawer: BaseMenuViewController { get }
    func goBack()
}

class PushNotificationsNavigator: PushNotificationsNavigatorProtocol {
    
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    required init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension PushNotificationsNavigatorProtocol {
    func goBack() {
        let navigationController = drawer.currentRootViewController as? NavigationController
        _ = navigationController?.popViewController(animated: true)
    }
}
