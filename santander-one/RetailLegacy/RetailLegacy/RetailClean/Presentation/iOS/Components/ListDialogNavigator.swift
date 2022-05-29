import Foundation

protocol ListDialogNavigator {
    func dismiss()
}

class ListDialogNavigatorImp: ListDialogNavigator {
    
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
    
    func dismiss() {
        drawer.currentRootViewController?.dismiss(animated: false)
    }
}
