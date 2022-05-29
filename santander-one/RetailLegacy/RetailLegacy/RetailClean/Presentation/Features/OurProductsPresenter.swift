import Foundation
import CoreFoundationLib

class OurProductsPresenter: ProductCollectionPresenter {
    
    override var screenId: String? {
        if sessionManager.isSessionActive {
            return TrackerPagePrivate.Contract().page
        } else {
            return TrackerPagePublic.PublicProducts().page
        }
    }
    
    private var publicProducts: [PublicProductItem] = []
    
    override func loadViewData() {
        super.loadViewData()
        view.textEmtpyLabel = dependencies.stringLoader.getString("generic_label_emptyListResult")
    }
    
    override func startUseCase() {
        UseCaseWrapper(
            with: useCaseProvider.getPublicProductsUseCase(),
            useCaseHandler: useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] (response) in
                guard let self = self else { return }
                self.publicProducts = response.publicProducts
                self.fillViews(items: self.publicProducts)
            }, onError: { [weak self] (error) in
                self?.showError(keyDesc: error?.getErrorDesc())
                self?.view.setSections([])
        })
    }
    
    override func didSelectElement(at position: IndexPath) {
        trackSelectProductEvent(at: position)
        let element = view.sections[position.item]
        guard let urlString = element.data.redirectionURL, let url = URL(string: urlString) else {
            return
        }
        navigator.openURL(url)
    }

    private func trackSelectProductEvent(at position: IndexPath) {
        if publicProducts.count > position.row {
            let publicProduct = publicProducts[position.row]
            if sessionManager.isSessionActive {
                trackEvent(eventId: TrackerPagePrivate.Contract.Action.selectProduct.rawValue,
                           parameters: [TrackerDimensions.productsId: publicProduct.id ?? ""])
            } else {
                trackEvent(eventId: TrackerPagePublic.PublicProducts.Action.selectProduct.rawValue,
                           parameters: [TrackerDimensions.productsId: publicProduct.id ?? ""])
            }
        }
    }
}
