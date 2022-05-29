//
//  PagerView.swift
//  toTest
//
//  Created by alvola on 01/10/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit
import CoreFoundationLib

public protocol PagerViewDelegate: AnyObject {
    func scrolledToNewOption()
}

public final class PagerView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet public weak var heightPagerControllerConstraint: NSLayoutConstraint!
    @IBOutlet public weak var scrollView: UIScrollView?
    @IBOutlet public weak var pagerController: UIPageControl?
    @IBOutlet public weak var titleLabel: UILabel?
    @IBOutlet public weak var slideTitleLabel: UILabel!
    @IBOutlet public weak var slideDescriptionLabel: UILabel?
    @IBOutlet public weak var contentView: UIView?
    @IBOutlet public weak var scrollViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet public weak var themeColorSelectorView: ThemeColorSelectorView!
    @IBOutlet public weak var scrollViewWidthConstraintBig: NSLayoutConstraint!
    @IBOutlet public weak var themeSelectorTopConstraint: NSLayoutConstraint!
    @IBOutlet public weak var gestureView: UIView!
    
    public weak var delegate: PagerViewDelegate?
    var pageSeparation: CGFloat = 28.0
    let swipeConstant: CGFloat = 1.3
    
    private var currentIndex: Int = 0 {
        didSet {
            if oldValue != currentIndex {
                delegate?.scrolledToNewOption()
            }
        }
    }
    private var bannedIndexes: [Int] = []
    private var currentSlides: [PageView] = [] {
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    internal func commonInit() {
        let nibName = String(describing: type(of: self))
        Bundle.module?.loadNibNamed(nibName, owner: self, options: nil)
        guard let content = contentView else { return }
        addSubview(content)
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        content.backgroundColor = UIColor.clear
        themeColorSelectorView.alpha = 0.0
        themeColorSelectorView.themeSelectorDelegate = self
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutScrollView()
        if Screen.isScreenSizeBiggerThanIphone8plus() == true {
            scrollViewWidthConstraint.isActive = false
            scrollViewWidthConstraintBig.isActive = true
        } else {
            if Screen.isScreenSizeBiggerThanIphone5() == false {
                heightPagerControllerConstraint.constant = 10
            }
            scrollViewWidthConstraint.isActive = true
            scrollViewWidthConstraintBig.isActive = false
        }
        
        if Screen.isScreenSizeBiggerThanIphone5() == true {
            themeSelectorTopConstraint.constant = 80
        }
        setupDescriptionLabelFont()
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        selectSlideViews()
        guard let scrollWidth = scrollView?.frame.width else { return }
        let contentOffsetX = scrollWidth * CGFloat(currentIndex)
        scrollView?.contentOffset = CGPoint(x: contentOffsetX, y: 0.0)
        animateIfNeededSelectorView()
    }
    
    public func setInfo(_ info: [PageInfo]) {
        self.info = info
        guard let lastPageInfo = info.last, lastPageInfo.isEditable == true  else {
            return
        }
        switch lastPageInfo.smartColorMode {
        case .red:
            themeColorSelectorView.toggleButtonType(buttonType: .red, toActive: true)
        case .black:
            themeColorSelectorView.toggleButtonType(buttonType: .black, toActive: true)
        default:()
        }
    }
    public func setTitle(_ title: LocalizedStylableText) { configureLabels(title)  }
    public func setBannedIndexes(_ idxs: [Int]) { bannedIndexes = idxs }
    public func selectedSlide() -> PageInfo { return info[currentSlides.firstIndex { $0.selected } ?? 0] }
    
    public func setCurrentSlide(_ index: Int) {
        self.currentIndex = index
        self.scrollToCurrentIndex(animated: false)
    }
    
    // MARK: - privateMethods
    
    private func configureLabels(_ title: LocalizedStylableText) {
        titleLabel?.applyStyle(LabelStylist(textColor: UIColor.black,
                                            font: UIFont.santander(family: .headline, type: .regular, size: 24),
                                            textAlignment: NSTextAlignment.left))
        titleLabel?.set(localizedStylableText: title)
        titleLabel?.set(lineHeightMultiple: 0.85)
        
        slideTitleLabel.applyStyle(LabelStylist(textColor: UIColor.black,
                                                font: UIFont.santander(family: .text, type: .bold, size: 20),
                                                textAlignment: NSTextAlignment.left))
        slideDescriptionLabel?.applyStyle(LabelStylist(textColor: UIColor.lisboaGray,
                                                       font: UIFont.santander(family: .text, type: .light, size: 16),
                                                       textAlignment: NSTextAlignment.left))
        slideDescriptionLabel?.set(lineHeightMultiple: 0.85)
    }
    
    private func configureScrollView() {
        guard let scrollView = scrollView else { return }
        
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        
        pagerController?.numberOfPages = currentSlides.count
        pagerController?.currentPage = 0
        pagerController?.isHidden = currentSlides.count <= 1
        pagerController?.hidesForSinglePage = true
        pagerController?.pageIndicatorTintColor = UIColor.silverDark
        pagerController?.currentPageIndicatorTintColor = UIColor.botonRedLight
        if #available(iOS 14, *) {
            pagerController?.backgroundStyle = .minimal
        } else {
            pagerController?.subviews.forEach {
                $0.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }
        }
        layoutSubviews()
        
        gestureView.isUserInteractionEnabled = true
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(gesture(sender:)))
        gesture.delegate = self
        gestureView.addGestureRecognizer(gesture)
    }
    
    private func layoutScrollView() {
        guard let scrollView = scrollView else { return }
        scrollView.contentSize = CGSize(width: scrollView.bounds.width * CGFloat(currentSlides.count),
                                        height: scrollView.bounds.height)
        scrollView.clipsToBounds = false
        var i = 0
        currentSlides.forEach {
            scrollView.addSubview($0)
            $0.frame = CGRect(x: scrollView.bounds.width * CGFloat(i),
                              y: 0,
                              width: scrollView.bounds.width,
                              height: scrollView.bounds.height)
            i += 1
        }
    }
    
    private func createSlides() {
        var slides: [PageView] = []
        info.forEach {
            guard let slide = Bundle.module?.loadNibNamed("PageView", owner: self, options: nil)?.first as? PageView else { return }
            slide.setInfo($0)
            slides.append(slide)
        }
        currentSlides = slides
    }
    
    private func selectSlideViews() {
        guard info.count > currentIndex else { return }
        pagerController?.currentPage = currentIndex
        slideTitleLabel?.set(localizedStylableText: info[currentIndex].title)
        slideDescriptionLabel?.set(localizedStylableText: info[currentIndex].description)
        slideDescriptionLabel?.set(lineHeightMultiple: 0.85)
        guard !bannedIndexes.contains(currentIndex) else { currentSlides[currentIndex].banned(true); return }
        currentSlides.enumerated().forEach({
            $0.element.selected($0.offset == currentIndex)
            $0.element.banned(false)
        })
    }
    
    private func setupDescriptionLabelFont() {
        guard var minFontSize = slideDescriptionLabel?.font.pointSize else { return }
        info.forEach {
            if let size = slideDescriptionLabel?.fontSizeWith($0.description.text), size < minFontSize {
                minFontSize = size
            }
        }
        slideDescriptionLabel?.font = slideDescriptionLabel?.font.withSize(minFontSize)
    }
    
    private func scrollToCurrentIndex(animated: Bool) {
        guard let scrollView = scrollView else { return }
        
        let contentOffsetX = scrollView.frame.width * CGFloat(currentIndex)
        scrollView.setContentOffset(CGPoint(x: contentOffsetX, y: 0.0), animated: animated)
    }
    
    @objc func gesture(sender: UIPanGestureRecognizer) {
        guard let scrollView = scrollView else { return }
        let translation = sender.translation(in: self)
        
        var movePosition = scrollView.contentOffset.x - translation.x * swipeConstant
        movePosition = max(0, min(movePosition, scrollView.contentSize.width))
        
        sender.setTranslation(CGPoint.zero, in: self)
        scrollView.setContentOffset(CGPoint(x: movePosition, y: 0.0), animated: false)
        
        if sender.state == .ended {
            scrollToCurrentIndex(animated: true)
        }
    }
    
    // MARK: - UIScrollViewDelegate methods
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        themeColorSelectorView.alpha = 0.0
        
        let newCurrentIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        guard newCurrentIndex < currentSlides.count else {
            return
        }
        currentIndex = newCurrentIndex
        
        selectSlideViews()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        animateIfNeededSelectorView()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        animateIfNeededSelectorView()
    }
    
    func animateIfNeededSelectorView() {
        guard
            let currentPage = pagerController?.currentPage,
            info.count > currentPage,
            self.info[currentPage].isEditable,
            currentPage == currentSlides.count-1
        else { return }
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseIn], animations: { [weak self] in
            self?.themeColorSelectorView.alpha = 1.0
        }, completion: nil)
    }
    
    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        let page = sender.currentPage
        guard let scrollWidth = scrollView?.frame.width else { return }
        
        let contentOffsetX = scrollWidth * CGFloat(page)
        scrollView?.contentOffset = CGPoint(x: contentOffsetX, y: 0.0)
    }
}

extension PagerView: ThemeColorSelectorViewDelegate {
    public func didSelectButton(_ buttonType: ButtonType) {
        if let lastPage = currentSlides.last {
            var imageName: String = "imgPgSmart"
            switch buttonType {
            case .red:
                imageName = "imgPgSmart"
            case .black:
                imageName = "imgYoungBlack"
            }
            lastPage.changeBackgroundImage(WithImageNamed: imageName)
        }
    }
}
