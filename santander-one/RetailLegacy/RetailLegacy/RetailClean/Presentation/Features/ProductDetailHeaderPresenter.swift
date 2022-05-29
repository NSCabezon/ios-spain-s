class ProductDetailHeaderPresenter: PrivatePresenter<ProductDetailHeaderViewController, ProductDetailNavigatorProtocol, ProductDetailHeaderPresenterProtocol>, ProductDetailProfileSeteable {
    
    private var product: CarouselItem!
    private var currentPage = 0
    weak var delegate: ProductSelectionDelegate?
    var productDetailProfile: ProductDetailProfile? {
        didSet {
            productDetailProfile?.detailProduct(completion: { [weak self] (product) in
                self?.product = product
            })
        }
    }
}

extension ProductDetailHeaderPresenter: Presenter {}

extension ProductDetailHeaderPresenter: ProductDetailHeaderPresenterProtocol {
 
    func numberOfItems() -> Int {
        return 1
    }
    
    func viewModel(for element: Int) -> CarouselItem {
        return product
    }

}
