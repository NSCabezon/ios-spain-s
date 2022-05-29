import Foundation
import CoreDomain

class BillsHomeNavigator: AppStoreNavigator {
    
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    required init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension BillsHomeNavigator: OperativesNavigatorProtocol {
    
    func navigateToFilterWith(_ parameters: BillAndTaxesFilterParameters, delegate: BillAndTaxesFilterDelegate) {
        let filterPresenter = presenterProvider.billsAndTaxesFilterPresenter(filter: parameters, delegate: delegate)
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(filterPresenter.view, animated: true)
    }
    
    func navigateToTransactionDetail(_ billAndAccounts: [BillAndAccount], selectedPosition: Int) {
        let transactionDetailContainerPresenter = presenterProvider.transactionDetailContainerPresenter
        transactionDetailContainerPresenter.product = billAndAccounts[selectedPosition]
        transactionDetailContainerPresenter.transactions = billAndAccounts
        transactionDetailContainerPresenter.selectedPosition = selectedPosition
        transactionDetailContainerPresenter.productHome = .bill
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(transactionDetailContainerPresenter.view, animated: true)
    }
    
    func goToPdfViewer(pdfData: Data) {
        let presenter = presenterProvider
            .pdfViewerPresenter(pdfData: pdfData, title: "toolbar_title_pdfExtract", pdfSource: .bill)
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(presenter.view, animated: true)
    }
}
