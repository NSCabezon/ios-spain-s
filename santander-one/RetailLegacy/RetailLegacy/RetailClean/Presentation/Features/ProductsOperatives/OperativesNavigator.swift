class OperativesNavigator: OperativesNavigatorProtocol {
    var drawer: BaseMenuViewController
    var presenterProvider: PresenterProvider
    
    required init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}
