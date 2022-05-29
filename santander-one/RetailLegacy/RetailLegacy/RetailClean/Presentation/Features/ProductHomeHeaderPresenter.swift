class ProductHomeHeaderPresenter: PrivatePresenter<ProductHomeHeaderViewController, ProductHomeNavigatorProtocol, ProductHomeHeaderPresenterProtocol>, ProductProfileSeteable {
    
    weak var delegate: ProductSelectionDelegate?
    var productProfile: ProductProfile? {
        didSet {
            productProfile?.productList(completion: { [weak self] (products, selectedIndex) in
                self?.products = products
                self?.view.totalElements(number: products.count)
                self?.view.reloadData { [weak self] in
                    self?.didSelectProduct(at: selectedIndex)
                    self?.currentPage = selectedIndex
                }
                self?.view.scrollToElement(position: selectedIndex)
                self?.view.selectPage(position: selectedIndex)
            })
        }
    }

    private var products = [CarouselItem]()
    private(set) var currentPage: Int?

    private func didSelectProduct(at index: Int) {
        guard currentPage != index else {
            return
        }
        view.selectPage(position: index)
        currentPage = index
        delegate?.didSelect(itemAt: index)
        
        (self.productProfile as? CoachmarkProfile)?.setNextProduct(index: index)
        
        //I NEED TO REMOVE COACH WHEN SELECTING PRODUCT TO RESET CAROUSEL COACHMARKS
        (self.productProfile?.delegate as? CoachmarkPresenter)?.resetCoachmarks()
        
        //SEARCH FOR A COACHMARK VIEW IN VIEW AND CALL COACHMARK PRESENTER WITH PRESENTING INFO
        self.view.findCoachmarks(neededIds: (self.productProfile as? CoachmarkProfile)?.headerIdentifiers ?? []) { _ in
            if let productHomePresenter = self.productProfile?.delegate as? ProductHomeCoachmarkPresenter {
                productHomePresenter.headerCoachmarksDidFinishLoad()
            }
        }
    }
    
    func syncWithProduct(at index: Int) {
        view.scrollToElement(position: index)
        didSelectProduct(at: index)
    }
    
    func selectNextProduct() {
        guard let currentPage = currentPage, currentPage < products.count - 1 else {
            return
        }
        trackSwipeEvent()

        let nextPage = currentPage + 1
        didSelectProduct(at: nextPage)
        view.scrollToElement(position: nextPage, animated: true)
    }
    
    func selectPreviousProduct() {
        guard let currentPage = currentPage, currentPage > 0 else {
            return
        }
        trackSwipeEvent()

        let previousPage = currentPage - 1
        didSelectProduct(at: previousPage)
        view.scrollToElement(position: previousPage, animated: true)
    }

    func selectProduct(at index: Int) {
        if currentPage != index {
            trackSwipeEvent()
            didSelectProduct(at: index)
        }
    }

    func updateProduct(product: CarouselItem, currentIndex: Int) {
        self.products[currentIndex] = product
        view.reloadData()
    }

    // MARK: - Private

    private func trackSwipeEvent() {
        if let screenId = productProfile?.screenId {
            let parameters = productProfile?.getTrackParameters()
            track(event: TrackerPagePrivate.Generic.Action.swipe.rawValue, screen: screenId, parameters: parameters ?? [:])
        }
    }
}

extension ProductHomeHeaderPresenter: Presenter {}

extension ProductHomeHeaderPresenter: ProductHomeHeaderPresenterProtocol {
    
    func viewModel(for element: Int) -> CarouselItem {
        return products[element]
    }
    
    func numberOfItems() -> Int {
        return products.count
    }    
}
