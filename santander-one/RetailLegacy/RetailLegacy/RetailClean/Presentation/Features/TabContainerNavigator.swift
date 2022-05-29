protocol TabContainerNavigatorProtocol: MenuNavigator, OperativesNavigatorProtocol, BaseWebViewNavigatable {
}

class TabContainerNavigator {
    
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    required init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension TabContainerNavigator: TabContainerNavigatorProtocol {}
