import UIKit
import CoreFoundationLib

class TransactionDetailNavigator: AppStoreNavigator {
        
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension TransactionDetailNavigator: PullOffersActionsNavigatorProtocol {}

extension TransactionDetailNavigator: TransactionDetailNavigatorProtocol {
    func goToPdfViewer(pdfData: Data, pdfSource: PdfSource) {
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(presenterProvider.pdfViewerPresenter(pdfData: pdfData, title: "toolbar_title_pdfExtract", pdfSource: pdfSource).view, animated: true)
    }
}
