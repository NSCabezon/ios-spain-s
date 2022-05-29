import Foundation

class PublicProductsPresenter: DualContainerPresenter<ProductCollectionViewController, ProductCollectionNavigatorProtocol, ProductCollectionPresenterProtocol, ProductCollectionViewController, ProductCollectionPresenterProtocol> {
    
    override func loadViewData() {
        if sessionManager.isSessionActive {
            presenterOption1 = DealsForYouPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
        }
        presenterOption2 = OurProductsPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
        super.loadViewData()
    }
    
    override var optionTitle1: LocalizedStylableText {
        return stringLoader.getString("publicProducts_tab_offer")
    }
    
    override var optionTitle2: LocalizedStylableText {
        return stringLoader.getString("publicProducts_tab_product")
    }
    
    override var title: String? {
        if sessionManager.isSessionActive {
            return stringLoader.getString("toolbar_title_personalProducts").text
        }
        return stringLoader.getString("toolbar_title_publicProducts").text
    }
}
