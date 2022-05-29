import UIKit
import UI
import CoreFoundationLib

protocol GeneralPagerViewDelegate: AnyObject {
    func currentIndexDidChange(_ index: Int)
}

class GeneralPagerView: DesignableView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var pagerController: UIPageControl?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var slideTitleLabel: UILabel!
    @IBOutlet weak var slideDescriptionLabel: UILabel?
    @IBOutlet weak var labelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topToNavigationBarConstraint: NSLayoutConstraint!
    @IBOutlet weak var topToTitleLabelConstraint: NSLayoutConstraint!
    
    private var currentIndex: Int = 0
    private var bannedIndexes: [Int] = []
    weak var delegate: GeneralPagerViewDelegate?
    
    let swipeConstant: CGFloat = 1.3

    private var currentSlides: [GeneralPageView] = [] {
        didSet {
            configureScrollView()
        }
    }
    
    private var info: [PageInfo] = [] {
        didSet {
            createSlides()
            selectSlideViews()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutScrollView()
    }
    
    func setInfo(_ info: [PageInfo]) { self.info = info }
    func setTitle(_ title: LocalizedStylableText?) { configureLabels(title)  }
    func setBannedIndexes(_ idxs: [Int]) { bannedIndexes = idxs }
    func selectedSlide() -> PageInfo { return info[currentSlides.firstIndex { $0.selected } ?? 0] }
    func setDelegate(_ delegate: GeneralPagerViewDelegate?) { self.delegate = delegate}
    
    func setCurrentSlide(_ index: Int) {
        self.currentIndex = index
        selectSlideViews()
        layoutSubviews()
        guard let scrollWidth = scrollView?.frame.width else { return }
        let contentOffsetX = scrollWidth * CGFloat(currentIndex)
        scrollView?.contentOffset = CGPoint(x: contentOffsetX, y: 0.0)
    }
    
    // MARK: - privateMethods
    
    var titlePager: LocalizedStylableText? {
        didSet {
            if let title = titlePager {
                titleLabel?.configureText(withLocalizedString: title,
                                          andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 20.0),
                                                                                               alignment: .left,
                                                                                               lineHeightMultiple: 0.85))
                labelHeightConstraint.constant = 28.0
            } else {
                titleLabel?.isHidden = true
                labelHeightConstraint.constant = 0.0
            }
        }
    }
    
    private func configureLabels(_ title: LocalizedStylableText?) {
        titleLabel?.textColor = .lisboaGray
        titlePager = title
        
        slideTitleLabel.textColor = .lisboaGray
        
        slideDescriptionLabel?.textColor = .lisboaGray
    }
    
    private func configureScrollView() {
        guard let scrollView = scrollView else { return }
        
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        
        pagerController?.numberOfPages = currentSlides.count
        pagerController?.currentPage = 0
        pagerController?.hidesForSinglePage = true
        pagerController?.isHidden = currentSlides.count <= 1
        pagerController?.pageIndicatorTintColor = .silverDark
        pagerController?.currentPageIndicatorTintColor = .botonRedLight
        if #available(iOS 14.0, *) {
            pagerController?.backgroundStyle = .minimal
        }
        
        scrollView.layoutIfNeeded()
        scrollView.setNeedsLayout()
        
        layoutSubviews()
    }
    
    private func layoutScrollView() {
        guard let scrollView = scrollView else { return }
        scrollView.contentSize = CGSize(width: scrollView.bounds.width * CGFloat(currentSlides.count),
                                        height: scrollView.bounds.height)
        scrollView.clipsToBounds = false
        var slide = 0
        currentSlides.forEach {
            scrollView.addSubview($0)
            $0.frame = CGRect(x: scrollView.bounds.width * CGFloat(slide),
                              y: 0,
                              width: scrollView.bounds.width,
                              height: scrollView.bounds.height)
            slide += 1
        }
        
    }
    
    private func createSlides() {
        var slides: [GeneralPageView] = []
        info.forEach {
            let slide = GeneralPageView()
            slide.setInfo($0)
            slides.append(slide)
            
        }
        currentSlides = slides
    }
    
    private func selectSlideViews() {
        if pagerController?.currentPage != currentIndex {
            delegate?.currentIndexDidChange(currentIndex)
        }
        
        pagerController?.currentPage = currentIndex
        slideTitleLabel?.configureText(withLocalizedString: info[currentIndex].title,
                                       andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 20.0),
                                                                                            alignment: .left))
        slideDescriptionLabel?.configureText(withLocalizedString: info[currentIndex].description,
                                             andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 16.0),
                                                                                                  alignment: .left,
                                                                                                  lineHeightMultiple: 0.85))
        
        guard !bannedIndexes.contains(currentIndex) else { currentSlides[currentIndex].banned(true); return }
        currentSlides.enumerated().forEach({
            $0.element.selected($0.offset == currentIndex)
            $0.element.banned(false)
        })
    }
    
    private func animateScrollToCurrentIndex() {
        guard let scrollView = scrollView else { return }

        let contentOffsetX = scrollView.frame.width * CGFloat(currentIndex)
        scrollView.setContentOffset(CGPoint(x: contentOffsetX, y: 0.0), animated: true)
    }
    
    @objc func gesture(sender: UIPanGestureRecognizer) {
        guard let scrollView = scrollView else { return }
        let translation = sender.translation(in: self)
        
        var movePosition = scrollView.contentOffset.x - translation.x * swipeConstant
        movePosition = max(0, min(movePosition, scrollView.contentSize.width))

        sender.setTranslation(CGPoint.zero, in: self)
        scrollView.setContentOffset(CGPoint(x: movePosition, y: 0.0), animated: false)

        if sender.state == .ended {
            animateScrollToCurrentIndex()
        }
    }
    
    // MARK: - UIScrollViewDelegate methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newCurrentIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        guard newCurrentIndex < currentSlides.count else {
            return
        }
        
        currentIndex = newCurrentIndex
        selectSlideViews()
    }
    
    @IBAction func pageControlSelectionAction(_ sender: UIPageControl) {
        let page = sender.currentPage
        guard let scrollWidth = scrollView?.frame.width else { return }
        
        let contentOffsetX = scrollWidth * CGFloat(page)
        scrollView?.contentOffset = CGPoint(x: contentOffsetX, y: 0.0)
    }
    
    func ajustTopToNavigationBar() {
        self.topToTitleLabelConstraint.isActive = false
        self.topToNavigationBarConstraint.isActive = true
    }
}
