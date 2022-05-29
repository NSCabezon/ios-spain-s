import Foundation
import CoreFoundationLib

class TransferEmittedDetailNavigator: TransferDetailNavigatorProtocol {
    
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    required init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
    
    func goToCancelTransferConfirmation(transferScheduled: TransferScheduled, scheduledTransferDetail: ScheduledTransferDetail, account: Account, operativeDelegate: OperativeLauncherDelegate) {
        let presenter = presenterProvider.cancelTransferConfirmationPresenter(transferScheduled: transferScheduled, scheduledTransferDetail: scheduledTransferDetail, account: account, operativeDelegate: operativeDelegate)
        presenter.view.modalPresentationStyle = .overCurrentContext
        drawer.present(presenter.view, animated: true)
        
    }
    
    func goToPdf(with data: Data, title: String, pdfSource: PdfSource) {
        let presenter = presenterProvider.pdfViewerPresenter(pdfData: data, title: title, pdfSource: pdfSource)
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(presenter.view, animated: true)
    }
}
