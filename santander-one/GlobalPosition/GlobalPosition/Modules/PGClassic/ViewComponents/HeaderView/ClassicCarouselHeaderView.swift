import UIKit

protocol ClassicCarouselDatasourceType: UICollectionViewDataSource, UICollectionViewDelegate {
    var numberOfItems: Int { get }
    var requiredHeight: CGFloat { get }
}

class ClassicCarouselHeaderView: DesignableView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    private var carouselDatasource: ClassicCarouselDatasourceType?
        
    override func commonInit() {
        super.commonInit()
        setupViews()
    }
    
    private func setupViews() {
        collectionView.register(ClassicCarouselCollectionViewCell.self, forCellWithReuseIdentifier: "classicCarouselCell")
        backgroundColor = .white
    }
    
    private func setupPageControl() {
        pageControl.isHidden = true
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .botonRedLight
        pageControl.pageIndicatorTintColor = .silverDark
        if #available(iOS 14.0, *) {
            pageControl.backgroundStyle = .minimal
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupPageControl()
    }
    
    fileprivate func updatePageController() {
        if let numberOfPages = self.carouselDatasource?.numberOfItems {
            self.pageControl.numberOfPages = numberOfPages
        }
    }
    
    func setCarouselDelegate(_ datasource: ClassicCarouselDatasourceType) {
        self.carouselDatasource = datasource
        self.collectionView.dataSource = datasource
        self.collectionView.delegate = datasource
        self.updatePageController()
    }
        
    func setPage(_ position: Int) {
        pageControl.currentPage = position
        setupPageControl()
    }
    
    func reloadData() {
        collectionView.reloadData()
        collectionViewHeight.constant = carouselDatasource?.requiredHeight ?? 0
        self.updatePageController()
    }
}
