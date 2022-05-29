//

import UIKit

class OrderDetailNavigator: OrderDetailNavigatorProtocol {
    var drawer: BaseMenuViewController
    var presenterProvider: PresenterProvider
    
    required init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}
