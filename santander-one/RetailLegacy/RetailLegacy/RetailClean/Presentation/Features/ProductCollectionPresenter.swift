import Foundation

class ProductCollectionPresenter: PrivatePresenter<ProductCollectionViewController, ProductCollectionNavigatorProtocol, ProductCollectionPresenterProtocol> {
    
    override func loadViewData() {
        super.loadViewData()
        
        startUseCase()
    }
    
    func startUseCase() {
        fatalError()
    }
    
    func fillViews(items: [ImageTitleCollectionProtocol]?) {
        guard let items = items else { return }
        
        let sections = items.map { item -> ImageTitleCollectionCellItem in
            let data = ImageTitleCollectionViewModel(title: item.text, redirectionURL: item.absoluteUrl, imageRelativeURL: item.icon, imageLoader: dependencies.imageLoader, imagePlaceholder: nil, offers: item.offers)
            return ImageTitleCollectionCellItem(data: data)
        }
        if sections.count == 0 {
            view.isEmptyViewVisible(visible: true)
            view.setSections([])
        } else {
            view.isEmptyViewVisible(visible: false)
            view.setSections(sections)
        }
    }
    
    func didSelectElement(at position: IndexPath) {
        fatalError()
    }
    
}

extension ProductCollectionPresenter: ProductCollectionPresenterProtocol {
    
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return true
    }
    
}
