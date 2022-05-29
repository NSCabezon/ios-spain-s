//

import Foundation

protocol CardPfdStatementNavigatorProtocol: OperativesNavigatorProtocol {
    func goToPdfViewer(pdfData: Data)
    func goToMonthsSelection(card: Card, months: [String], delegate: CardPdfLauncher, placeholders: [StringPlaceholder])
    func close()
}

class CardPfdStatementNavigator: CardPfdStatementNavigatorProtocol {
    
    var presenterProvider: PresenterProvider
    var drawer: BaseMenuViewController
    
    required init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
    
    func goToMonthsSelection(card: Card, months: [String], delegate: CardPdfLauncher, placeholders: [StringPlaceholder]) {
        let monthSelectionPresenter = presenterProvider.monthSelectionDialogPresenter(card: card, withMonths: months, delegate: delegate, placeholders: placeholders)
        monthSelectionPresenter.view.modalTransitionStyle = .crossDissolve
        monthSelectionPresenter.view.modalPresentationStyle = .overCurrentContext
        drawer.present(monthSelectionPresenter.view, animated: true)
    }
    
    func goToPdfViewer(pdfData: Data) {
        let presenter = presenterProvider.pdfViewerPresenter(pdfData: pdfData, title: "toolbar_title_pdfExtract", pdfSource: .cardPDFExtract)
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(presenter.view, animated: true)
    }
    
    func close() {
        let navigationController = drawer.currentRootViewController as? NavigationController
        _ = navigationController?.popViewController(animated: true)
    }
}
