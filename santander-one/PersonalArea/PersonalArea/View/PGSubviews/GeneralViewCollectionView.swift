//
//  GeneralViewCollectionView.swift
//  PersonalArea
//
//  Created by Carlos Gutiérrez Casado on 31/12/2019.
//

import UIKit
import UI
import CoreFoundationLib
import Foundation

protocol GeneralViewCollectionViewDelegate: AnyObject {
    func didSelectPageInfo(_ pageInfo: PageInfo)
    func didBegingScrolling()
    func didEndScrolling()
    func didEndScrollingSelectedItem()
}

protocol PageControlDelegate: AnyObject {
    func didPageChange(page: Int)
}

final class GeneralViewCollectionView: UIView {
    private var view: UIView?
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet weak var personalAreaCollectionView: PersonalAreaCollectionView!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var slideTitleLabel: UILabel?
    @IBOutlet private weak var slideDescriptionLabel: UILabel?
    @IBOutlet private weak var topCollectionViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelHeightConstraint: NSLayoutConstraint!
    weak var generalViewCollectionViewDelegate: GeneralViewCollectionViewDelegate?
    private var selectedPageInfo: PageInfo?
    private var pageView = GeneralPageView()
    private var bannedIndexes: [Int] = []
    weak var photoThemeDelegate: PhotoThemeViewControllerProtocol?
    
    var titlePage: LocalizedStylableText? {
        didSet {
            if let title = titlePage {
                self.titleLabel?.configureText(withLocalizedString: title,
                                          andConfiguration: LocalizedStylableTextConfiguration(font: .santander(size: 20.0),
                                                                                               alignment: .left,
                                                                                               lineHeightMultiple: 0.85))
                self.labelHeightConstraint.constant = 28.0
                self.titleLabel?.isHidden = false
                //self.titleLabel?.accessibilityIdentifier =
            } else {
                self.titleLabel?.isHidden = true
                self.labelHeightConstraint.constant = 0.0
            }
        }
    }
    
    private var info: [PageInfo] = [] {
        didSet {
            self.personalAreaCollectionView.arrPageInfo = info
        }
    }
    
    private var currentSlides: [GeneralPageView] = []
    
    private var arrSelectedPageInfo: [PageInfo] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.slideDescriptionLabel?.layoutSubviews()
        self.setupDescriptionLabelFont()
    }
    
    func setInfo(_ arrPageInfo: [PageInfo]) {
        self.info = arrPageInfo
        self.setupPageControl()
    }
    
    func setLabels(_ pageInfo: PageInfo) {
        self.configureLabels(with: pageInfo)
    }
    
    func setBannedIndexes(_ idxs: [Int]) {
        self.bannedIndexes = idxs
    }
    
    func selectedSlide() -> PageInfo? {
        return self.arrSelectedPageInfo.first
    }
    
    func configureLabels(with pageInfo: PageInfo) {
        self.slideTitleLabel?.configureText(withLocalizedString: pageInfo.title,
                                       andConfiguration: LocalizedStylableTextConfiguration(font: .santander(type: .bold, size: 20.0)))
        self.slideTitleLabel?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.slideTitleLabel
        self.slideDescriptionLabel?.configureText(withLocalizedString: pageInfo.description,
                                             andConfiguration: LocalizedStylableTextConfiguration(font: .santander(type: .light, size: 16.0),
                                                                                                  alignment: .left))
        self.slideDescriptionLabel?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.slideDescriptionLabel
    }
    
    func setCurrentPage(_ currentIndex: Int) {
        self.configureLabels(with: info[currentIndex])
        let selectedPageIndexPath = IndexPath(row: currentIndex, section: 0)
        self.personalAreaCollectionView.setPageSelected(selectedPageIndexPath)
        self.personalAreaCollectionView.reloadData()
        self.personalAreaCollectionView.scrollToItem(at: selectedPageIndexPath, at: .centeredHorizontally, animated: false)
        self.generalViewCollectionViewDelegate?.didSelectPageInfo(self.info[currentIndex])
        self.selectedPageInfo = self.info[currentIndex]
    }
    
    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        let index = IndexPath(item: sender.currentPage, section: 0)
        self.personalAreaCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
    }
}

private extension GeneralViewCollectionView {
    func setupView() {
        self.xibSetup()
        self.setupLabels()
        self.setupPageControl()
        self.personalAreaCollectionView.personalAreaDelegate = self
        self.personalAreaCollectionView.pageControlDelegate = self
        self.addGradientToView()
        self.setAccessibilityIdentifiers()
    }
    
    func xibSetup() {
        self.view = loadViewFromNib()
        self.view?.frame = bounds
        self.view?.backgroundColor = .clear
        self.addSubview(view ?? UIView())
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        
        return nib.instantiate(withOwner: self, options:
            nil)[0] as? UIView ?? UIView()
    }
    
    func addGradientToView() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(red: 245.0 / 255.0,
                                        green: 249.0 / 255.0,
                                        blue: 252.0 / 255.0,
                                        alpha: 1.0),
                                UIColor.white]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = bounds
        self.gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setupPageControl() {
        let pages = self.personalAreaCollectionView.arrPageInfo.count
        guard pages != 0 else { return }
        self.updatePageControl(pages)
    }
    
    func setupDescriptionLabelFont() {
        guard var minFontSize = self.slideDescriptionLabel?.font.pointSize else { return }
        self.info.forEach {
            if let size = self.slideDescriptionLabel?.fontSizeWith($0.description.text), size < minFontSize {
                minFontSize = size
            }
        }
        self.slideDescriptionLabel?.font = self.slideDescriptionLabel?.font.withSize(minFontSize)
    }
    
    func updatePageControl(_ numberOfItems: Int) {
        self.pageControl.numberOfPages = numberOfItems
        self.pageControl.hidesForSinglePage = true
        self.pageControl.isHidden = numberOfItems <= 1
        self.pageControl.pageIndicatorTintColor = .silverDark
        self.pageControl.currentPageIndicatorTintColor = .botonRedLight
        if #available(iOS 14.0, *) {
            self.pageControl.backgroundStyle = .minimal
        }
    }
    
    func setupLabels() {
        self.titleLabel?.isHidden = true
        self.titleLabel?.textColor = .lisboaGray
        self.slideTitleLabel?.textColor = .lisboaGray
        self.slideDescriptionLabel?.textColor = .lisboaGray
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.generalViewCollectionTitle
        self.personalAreaCollectionView.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.generalViewCollectionView
        self.pageControl.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.generalViewPageControl
    }
}

extension GeneralViewCollectionView: PageControlDelegate {
    func didPageChange(page: Int) {
        self.pageControl.currentPage = page
    }
}

extension GeneralViewCollectionView: PersonalAreaCollectionViewDelegate {
    func populateCollectionView(with arrPageInfo: [PageInfo]) {
        self.personalAreaCollectionView.reloadData()
    }
    
    func didSelectPageInfo(_ pageInfo: PageInfo) {
        self.configureLabels(with: pageInfo)
        self.arrSelectedPageInfo.removeAll()
        self.arrSelectedPageInfo.append(pageInfo)
        self.selectedPageInfo = pageInfo
        self.generalViewCollectionViewDelegate?.didSelectPageInfo(pageInfo)
    }
    
    func didBegingScrolling() {
        self.generalViewCollectionViewDelegate?.didBegingScrolling()
    }
    
    func didEndScrolling() {
        self.generalViewCollectionViewDelegate?.didEndScrolling()
        self.photoThemeDelegate?.didSwipe()
        
    }
    
    func didEndScrollingSelectedItem() {
        self.generalViewCollectionViewDelegate?.didEndScrollingSelectedItem()
    }
    
}

extension GeneralViewCollectionView {
    var selectedPageIndex: Int {
        return self.pageControl.currentPage
    }
    
    var selectedPage: PageInfo? {
        return self.selectedPageInfo
    }
}
