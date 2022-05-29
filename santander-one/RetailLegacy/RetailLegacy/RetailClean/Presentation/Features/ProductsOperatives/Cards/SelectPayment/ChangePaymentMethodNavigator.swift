//

import Foundation

protocol ChangePaymentMethodNavigatorProtocol {
    func goToSelectSubtype(delegate: SelectCardModifyPaymentFormDelegate, info: PaymentMethodSubtypeInfo)
    func goBack()
    func close()
}

class ChangePaymentMethodNavigator {
    
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension ChangePaymentMethodNavigator: ChangePaymentMethodNavigatorProtocol {
    func goToSelectSubtype(delegate: SelectCardModifyPaymentFormDelegate, info: PaymentMethodSubtypeInfo) {
        let presenter = presenterProvider.paymentMethodSubtypeSelectorPresenter(delegate: delegate, info: info)
        let view = presenter.view
        guard let navigator = drawer.currentRootViewController as? NavigationController else { return }
        navigator.pushViewController(view, animated: true)
    }
    
    func goBack() {
        let navigationController = drawer.currentRootViewController as? NavigationController
        _ = navigationController?.popViewController(animated: true)
    }
    
    func close() {
        let navigationController = drawer.currentRootViewController as? NavigationController
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
