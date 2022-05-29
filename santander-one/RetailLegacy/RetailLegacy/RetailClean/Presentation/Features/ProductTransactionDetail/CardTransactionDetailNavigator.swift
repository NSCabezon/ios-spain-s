import Foundation
import CoreFoundationLib

class CardTransactionDetailNavigator: TransactionDetailNavigatorProtocol, OperativesNavigatorProtocol {
    
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    func goToPdfViewer(pdfData: Data, pdfSource: PdfSource) {
        let presenter = presenterProvider.pdfViewerPresenter(pdfData: pdfData, title: "toolbar_title_pdfExtract", pdfSource: .cardTransactionsDetail)
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(presenter.view, animated: true)
    }
    
    required init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}
