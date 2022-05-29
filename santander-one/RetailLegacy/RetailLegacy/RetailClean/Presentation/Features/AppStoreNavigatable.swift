import UIKit
import StoreKit

protocol AppStoreNavigatable: UrlActionsCapable {
    func openAppStore(id: Int)
}

class AppStoreNavigator: StoreProductViewControllerDelegate, AppStoreNavigatable {}

class StoreProductViewControllerDelegate: NSObject {}

extension StoreProductViewControllerDelegate: SKStoreProductViewControllerDelegate {
    func openAppStore(id: Int) {
        guard let topViewController = UINavigationController.topVisibleViewController else {
            return
        }
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        let parameters = [SKStoreProductParameterITunesItemIdentifier: NSNumber(value: id)]
        storeViewController.loadProduct(withParameters: parameters, completionBlock: nil)
        topViewController.present(storeViewController, animated: true, completion: nil)
    }
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
