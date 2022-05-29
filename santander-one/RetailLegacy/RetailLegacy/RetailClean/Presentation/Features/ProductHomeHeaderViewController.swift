import UIKit
import UI

protocol ProductHomeHeaderPresenterProtocol {
    func numberOfItems() -> Int
    func viewModel(for element: Int) -> CarouselItem

    func selectNextProduct()
    func selectPreviousProduct()
    func selectProduct(at index: Int)
}

protocol ProductSelectionDelegate: class {
    func didSelect(itemAt position: Int)
}

class ProductHomeHeaderViewController: BaseViewController<ProductHomeHeaderPresenterProtocol>, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ToolTipDisplayer, DynamicToolTipDisplayer {
    
    override class var storyboardName: String {
        return "ProductHome"
    }
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControlBottomSpaceConstraint: NSLayoutConstraint!
    
    private struct Constants {
        static let smallSpace: CGFloat = -8
        static let extraSpace: CGFloat = -2
    }
    
    override func prepareView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ProductGenericCardCollectionViewCell", bundle: .module), forCellWithReuseIdentifier: "ProductGenericCardCollectionViewCell")
        collectionView.register(UINib(nibName: "ProductCreditCardCollectionViewCell", bundle: .module), forCellWithReuseIdentifier: "ProductCreditCardCollectionViewCell")
        collectionView.register(UINib(nibName: "ProductAccountCollectionViewCell", bundle: .module), forCellWithReuseIdentifier: "ProductAccountCollectionViewCell")
        collectionView.register(UINib(nibName: "ProductInsuranceCollectionViewCell", bundle: .module), forCellWithReuseIdentifier: "ProductInsuranceCollectionViewCell")
        
        previousButton.isExclusiveTouch = true
        nextButton.isExclusiveTouch = true
        
        nextButton.setImage(Assets.image(named: "icnArrowRightMadridHomeCarousel"), for: .normal)
        previousButton.setImage(Assets.image(named: "icnArrowLeft"), for: .normal)
    }
    
    func reloadData(completion: (() -> Void)? = nil) {
        guard let strongCollectionView = collectionView else { return }
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        strongCollectionView.reloadData()
        CATransaction.commit()
    }
    
    func totalElements(number: Int) {
        guard let strongPageControl = pageControl else { return }
        strongPageControl.numberOfPages = number
        checkPageControlSize()
    }
    
    func scrollToElement(position: Int, animated: Bool = false) {
        guard collectionView != nil else { return }
        collectionView.scrollToItem(at: IndexPath(item: position, section: 0), at: .centeredHorizontally, animated: animated)
        updateBackAndForwardButtons(position)
    }
    
    func selectPage(position: Int) {
        guard pageControl != nil else { return }
        pageControl.currentPage = position
        updateBackAndForwardButtons(position)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        checkPageControlSize()
    }
    
    private func checkPageControlSize() {
        pageControl.isHidden = pageControl.frame.width > view.frame.width - 16 //8 pixeles margen en cada lado
    }
    
    // MARK: - UICollectionViewDelegate
    
    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfItems()
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = presenter.viewModel(for: indexPath.row)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.identifier, for: indexPath)
        viewModel.configure(cell: cell)
       
        if let cell = cell as? ToolTipCompatible {
            cell.toolTipDelegate = self
        }

        if let cell = cell as? DynamicToolTipCompatible {
            cell.dynamicToolTipDelegate = self
        }
        return cell
    }

    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let width = view.bounds.width
        let currentPage = Int(offset/width)
        presenter.selectProduct(at: currentPage)
        updateBackAndForwardButtons(currentPage)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        previousButton.isHidden = true
        nextButton.isHidden = true
    }
    
    private func updateBackAndForwardButtons(_ currentPage: Int) {
        previousButton.isHidden = currentPage == 0
        nextButton.isHidden = currentPage == presenter.numberOfItems() - 1
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        previousButton.isHidden = true
        presenter.selectPreviousProduct()
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        nextButton.isHidden = true
        presenter.selectNextProduct()
    }
    
}
