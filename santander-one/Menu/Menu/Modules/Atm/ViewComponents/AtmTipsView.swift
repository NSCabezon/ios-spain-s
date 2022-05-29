//
//  AtmTipsView.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 02/09/2020.
//

import UIKit
import CoreFoundationLib
import UI

protocol AtmTipsViewDelegate: AnyObject {
    func didSelectTip(_ viewModel: AtmTipViewModel)
}

final class AtmTipsView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    weak var tipDelegate: AtmTipsViewDelegate?
    private var tips: [AtmTipViewModel] = []
    
    private var style = AtmTipsViewStyle() {
        didSet {
            setupView()
        }
    }
    
    override var backgroundColor: UIColor? {
        get {
            return self.view?.backgroundColor
        }
        set {
            self.view?.backgroundColor = newValue
        }
    }
    
    var isEmpty: Bool {
        return self.tips.isEmpty
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModels(_ viewModels: [AtmTipViewModel]) {
        self.tips = viewModels
        self.collectionView.reloadData()
    }
    
    func setStyle(_ style: AtmTipsViewStyle) {
        self.style = style
    }
    
    func setTitle(_ title: LocalizedStylableText) {
        self.titleLabel.attributedText = nil
        self.titleLabel.configureText(withLocalizedString: title)
    }
}

private extension AtmTipsView {
    
    func setupView() {
        self.view?.backgroundColor = style.mainViewBackgroundColor
        
        self.titleLabel.font = style.titleFont
        self.titleLabel.textColor = style.titleTextColor
        self.titleLabel.configureText(withKey: "tips_title_ourTips")
        self.collectionView.register(UINib(nibName: style.collectionViewCellIdentifier,
                                           bundle: .module),
                                     forCellWithReuseIdentifier: style.collectionViewCellIdentifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.clipsToBounds = false
        self.collectionView.setCollectionViewLayout(style.collectionViewLayout ?? self.collectionViewLayout(),
                                                    animated: false)
        self.collectionView.backgroundColor = style.collectionViewBackgroundColor
        self.collectionView.contentInset = style.collectionViewInset
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.reloadData()
        
        self.titleLabelTopConstraint.constant = style.titleTopSpace
        self.titleLabelBottomConstraint.constant = style.titleBottomSpace
        self.collectionViewBottomConstraint.constant = style.collectionViewBottomSpace
        self.addAccessibilityIdentifiers()
        self.layoutIfNeeded()
    }
    
    func collectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 232, height: 216)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        return layout
    }
    
    func addAccessibilityIdentifiers() {
        self.view?.accessibilityIdentifier = AccessibilityAtm.atmCarouselTips.rawValue
        self.titleLabel.accessibilityIdentifier = AccessibilityAtm.atmTipTitle.rawValue
    }
}

extension AtmTipsView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return style.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tips.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tipCell = collectionView.dequeueReusableCell(withReuseIdentifier: style.collectionViewCellIdentifier, for: indexPath)
        (tipCell as? AtmTipCollectionViewCellProtocol)?.setViewModel(self.tips[indexPath.row])
        return tipCell
    }
}

extension AtmTipsView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewModel = self.tips[indexPath.row]
        self.tipDelegate?.didSelectTip(viewModel)
    }
}

extension AtmTipsView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return style.collectionViewInset
    }
}

struct AtmTipViewModel {
    let title: LocalizedStylableText
    let description: LocalizedStylableText
    let baseUrl: String?
    let entity: PullOfferTipEntity
    let highlightedDescriptionKey: String?
    
    var tipImageUrl: String? {
        guard let baseUrl = self.baseUrl else { return nil }
        guard let icon = self.entity.icon else { return nil }
        return String(format: "%@%@", baseUrl, icon)
    }
    
    var isHighlighted: Bool {
        return highlightedDescriptionKey != nil
    }
    
    var tag: String? {
        entity.tag
    }
    
    init(_ entity: PullOfferTipEntity, baseUrl: String?, highlightedDescriptionKey: String? = nil) {
        self.title = localized(entity.title ?? "")
        self.description = localized(entity.description ?? "")
        self.baseUrl = baseUrl
        self.entity = entity
        self.highlightedDescriptionKey = highlightedDescriptionKey
    }
    
    func highlight(_ baseString: NSAttributedString?) -> NSAttributedString {
        guard let baseString = baseString, let highlightedDescriptionKey = highlightedDescriptionKey else { return NSAttributedString() }
        let ranges = baseString.string.ranges(of: highlightedDescriptionKey.trim()).map { NSRange($0, in: highlightedDescriptionKey) }
        return ranges.reduce(NSMutableAttributedString(attributedString: baseString)) {
            $0.addAttribute(.backgroundColor, value: UIColor.lightYellow, range: $1)
            return $0
        }
    }
}

class AtmTipsViewStyle {
    var mainViewBackgroundColor: UIColor
    var titleFont: UIFont
    var titleTextColor: UIColor
    var collectionViewCellIdentifier: String
    var collectionViewBackgroundColor: UIColor
    var collectionViewInset: UIEdgeInsets
    var collectionViewLayout: UICollectionViewFlowLayout?
    var titleTopSpace: CGFloat
    var titleBottomSpace: CGFloat
    var collectionViewBottomSpace: CGFloat
    var numberOfSections = 1
    
    init() {
        mainViewBackgroundColor = UIColor.blueAnthracita
        titleFont = UIFont.santander(size: 20)
        titleTextColor = UIColor.white
        collectionViewCellIdentifier = "AtmTipCollectionViewCell"
        collectionViewBackgroundColor = UIColor.blueAnthracita
        collectionViewInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 16)
        titleTopSpace = 23.0
        titleBottomSpace = 15.0
        collectionViewBottomSpace = 30.0
    }
    
    static func homeTipsStyle() -> AtmTipsViewStyle {
        let style = AtmTipsViewStyle()
        style.mainViewBackgroundColor = .white
        style.titleTextColor = .lisboaGray
        style.titleFont = .santander(size: 18.0)
        style.collectionViewBackgroundColor = .white
        style.collectionViewCellIdentifier = "GlobalSearchAdviseAtmCollectionViewCell"
        style.titleTopSpace = 26.0
        style.titleBottomSpace = 16.0
        style.collectionViewBottomSpace = 22.0
        style.collectionViewInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 16)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 206, height: 195)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        style.collectionViewLayout = layout
        style.numberOfSections = 1
        return style
    }
    
    static func interestTipsStyle() -> AtmTipsViewStyle {
        let style = AtmTipsViewStyle()
        style.mainViewBackgroundColor = .white
        style.titleTextColor = .lisboaGray
        style.titleFont = .santander(size: 18.0)
        style.collectionViewBackgroundColor = .white
        style.titleTopSpace = 8.0
        style.titleBottomSpace = 23.0
        style.collectionViewBottomSpace = 25.0
        style.collectionViewInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 16)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 264, height: 164)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        style.collectionViewLayout = layout
        style.numberOfSections = 1
        return style
    }
    
    static func homeTipsSmartStyle() -> AtmTipsViewStyle {
        let style = AtmTipsViewStyle.homeTipsStyle()
        style.mainViewBackgroundColor = .lightGray40
        style.collectionViewBackgroundColor = .lightGray40
        return style
    }
}
