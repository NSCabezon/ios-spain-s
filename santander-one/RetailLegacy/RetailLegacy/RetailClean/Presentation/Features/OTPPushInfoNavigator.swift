import Foundation

protocol OTPPushInfoNavigatorProtocol: OperativesNavigatorProtocol {
    func dismiss()
}

class OTPPushInfoNavigator: OTPPushInfoNavigatorProtocol {
    
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
    
    func dismiss() {
        let navigationController = drawer.currentRootViewController as? NavigationController
        _ = navigationController?.popViewController(animated: true)
    }
}
