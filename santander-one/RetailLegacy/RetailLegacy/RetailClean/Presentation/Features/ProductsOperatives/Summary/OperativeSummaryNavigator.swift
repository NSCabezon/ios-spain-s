import Foundation
import CoreFoundationLib

protocol OperativeSummaryNavigatorProtocol: PullOffersActionsNavigatorProtocol {
    func goToPdf(with data: Data, title: String, pdfSource: PdfSource)
}

class OperativeSummaryNavigator: AppStoreNavigator, OperativeSummaryNavigatorProtocol {
    
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
    
    func goToPdf(with data: Data, title: String, pdfSource: PdfSource) {
        let presenter = presenterProvider.pdfViewerPresenter(pdfData: data, title: title, pdfSource: pdfSource)
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(presenter.view, animated: true)
    }
}
