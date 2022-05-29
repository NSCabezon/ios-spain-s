import Foundation

protocol GenericLandingPushNavigatorProtocol: UrlActionsCapable {

}

class GenericLandingPushNavigator: GenericLandingPushNavigatorProtocol {
    
    let drawer: BaseMenuViewController
    let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.drawer = drawer
        self.presenterProvider = presenterProvider
    }
    
}
