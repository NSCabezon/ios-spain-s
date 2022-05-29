import Foundation

protocol PersonalManagerNavigatorProtocol: MenuNavigator, PullOffersActionsNavigatorProtocol {}

enum ManagerType {
    case withoutManager
    case withoutOfficeManager
    case withOfficeManager
    case withoutPersonalManager
    case withPersonalManager
}

class PersonalManagerNavigator: AppStoreNavigator {
    var drawer: BaseMenuViewController
    var presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension PersonalManagerNavigator: PersonalManagerNavigatorProtocol {}
