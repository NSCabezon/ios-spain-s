import Foundation

protocol NoSepaNavigatorProtocol {
    func goToPdfViewer(pdfData: Data)
    func goToFavourites(delegate: OnePayTransferDestinationDelegate, country: SepaCountryInfo, currency: SepaCurrencyInfo)
}

class NoSepaNaviagator: NoSepaNavigatorProtocol {
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
    
    func goToPdfViewer(pdfData: Data) {
        let navigator = drawer.currentRootViewController as? NavigationController
        navigator?.pushViewController(presenterProvider.pdfViewerPresenter(pdfData: pdfData, title: "toolbar_title_ratesExpenses", pdfSource: .nosepa).view, animated: true)
    }
    
    func goToFavourites(delegate: OnePayTransferDestinationDelegate, country: SepaCountryInfo, currency: SepaCurrencyInfo) {
        let navigationController = drawer.currentRootViewController as? NavigationController
        let presenter = presenterProvider.onePayNoSepaTransferFavouritesPresenter(delegate: delegate, country: country, currency: currency)
        let view = presenter.view
        view.modalPresentationStyle = .overCurrentContext
        navigationController?.present(view, animated: true, completion: nil)
    }
}
