protocol CancelTransferConfirmationNavigatorProtocol: OperativesNavigatorProtocol {
    func dismiss(completion: (() -> Void)?)
}

class CancelTransferConfirmationNavigator {
    
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    required init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
    
}

extension CancelTransferConfirmationNavigator: CancelTransferConfirmationNavigatorProtocol {
    func dismiss(completion: (() -> Void)?) {
        drawer.dismiss(animated: true, completion: completion)
    }
}
