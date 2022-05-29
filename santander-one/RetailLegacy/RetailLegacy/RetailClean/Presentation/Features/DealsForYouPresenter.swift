import Foundation

class DealsForYouPresenter: ProductCollectionPresenter {

    override var screenId: String? {
        if sessionManager.isSessionActive {
            return TrackerPagePrivate.ContractOffersForYou().page
        } else {
            return nil
        }
    }
    
    private var categoriesList: [PullOffersConfigCategory] = []

    override func loadViewData() {
        super.loadViewData()
        view.textEmtpyLabel = dependencies.stringLoader.getString("contract_label_emptyOffer")
    }
    
    override func startUseCase() {
        UseCaseWrapper(
            with: useCaseProvider.getPublicCategoriesUseCase(),
            useCaseHandler: useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] (response) in
                self?.categoriesList = response.categories ?? []
                self?.fillViews(items: response.categories)            
            }, onError: { [weak self] (error) in
                self?.showError(keyDesc: error?.getErrorDesc())
                self?.view.setSections([])
        })
    }
    
    override func didSelectElement(at position: IndexPath) {
        let element = view.sections[position.item]
        if let offers = element.data.offers {
            if categoriesList.count > position.row {
                let category = categoriesList[position.row]
                trackEvent(eventId: TrackerPagePrivate.ContractOffersForYou.Action.selectCategory.rawValue, parameters: [TrackerDimensions.categoryId: category.id ?? ""])
                navigator.goToPullOfferBanners(offers, category.id ?? "")
            }
        }
    }
}
