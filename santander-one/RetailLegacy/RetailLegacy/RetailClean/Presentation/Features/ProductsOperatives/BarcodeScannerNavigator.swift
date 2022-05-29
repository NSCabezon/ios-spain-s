//

import UIKit

class BarcodeScannerNavigator {
    
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

protocol BarcodeScannerNavigatorProtocol {
    func goToError(title: LocalizedStylableText, description: LocalizedStylableText, delegate: ScannerErrorPresenterDelegate)
    func goBack(completion: @escaping () -> Void)
}

extension BarcodeScannerNavigator: BarcodeScannerNavigatorProtocol {
    
    func goToError(title: LocalizedStylableText, description: LocalizedStylableText, delegate: ScannerErrorPresenterDelegate) {
        let navigationController = drawer.currentRootViewController as? NavigationController
        let presenter = presenterProvider.billsAndTaxesOperatives.scannerErrorPresenter(title: title, description: description)
        presenter.delegate = delegate
        navigationController?.pushViewController(presenter.view, animated: false)
    }
    
    func goBack(completion: @escaping () -> Void) {
        let navigationController = drawer.currentRootViewController as? NavigationController
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion()
        }
        _ = navigationController?.popViewController(animated: true)
        CATransaction.commit()
    }
}
