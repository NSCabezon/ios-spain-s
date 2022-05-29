import UIKit

protocol CustomerServiceNavigatorProtocol: MenuNavigator, BaseWebViewNavigatable {
    func tryOpen(stringUrl: String?, or otherStringURL: String?)
    func call(number: String)
}

class CustomerServiceNavigator: AppStoreNavigator {
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
        super.init()
    }
}

extension CustomerServiceNavigator: CustomerServiceNavigatorProtocol {
    
    func tryOpen(stringUrl: String?, or otherStringURL: String?) {
        if let stringUrl = stringUrl, let url = URL(string: stringUrl) {
            if canOpen(url) {
                open(url)
                return
            }
        }
        if let otherStringURL = otherStringURL, let url = URL(string: otherStringURL) {
            open(url)
        }
    }
    
    func call(number: String) {
        guard let numberUrl = URL(string: "tel://\(number.replacingOccurrences(of: " ", with: ""))") else { return }
        open(numberUrl)
    }
    
}

extension CustomerServiceNavigator: PullOffersActionsNavigatorProtocol {}
