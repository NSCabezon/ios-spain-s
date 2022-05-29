protocol SOFIANavigatorProtocol: AppStoreNavigatable & MenuNavigator {
}

class SOFIANavigator: AppStoreNavigator {
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
        super.init()
    }
}

extension SOFIANavigator: SOFIANavigatorProtocol {}
