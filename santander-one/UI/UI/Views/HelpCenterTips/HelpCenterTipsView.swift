import UIKit
import CoreFoundationLib

public protocol HelpCenterTipsViewDelegate: AnyObject {
    func didSelectTip(_ viewModel: Any)
    func didSelectSeeAllTips()
    func scrollViewDidEndDecelerating()
}

public final class HelpCenterTipsView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    public weak var tipDelegate: HelpCenterTipsViewDelegate?
    private var tips: [Any] = []
    private let seeAllTipsSection = 1
    @IBOutlet weak var seeAllTipsLabel: UILabel!
    @IBOutlet weak var seeAllTipsButtton: UIButton!
    private let loadingView = LoadingCollectionView()
    private let emptyView = EmptyCollectionView()
    private var addAccessibilitySuffix = false
    
    private var style = HelpCenterTipsViewStyle() {
        didSet {
            setupView()
        }
    }
    
    public override var backgroundColor: UIColor? {
        get {
            return self.view?.backgroundColor
        }
        set {
            self.view?.backgroundColor = newValue
        }
    }
    
    public var isEmpty: Bool {
        return self.tips.isEmpty
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setViewModels(_ viewModels: [Any], addAccessibilitySuffix: Bool = false) {
        self.addAccessibilitySuffix = addAccessibilitySuffix
        self.stopLoading()
        self.collectionView.backgroundView = nil
        self.tips = viewModels
        self.collectionView.reloadData()
    }
    
    public func setStyle(_ style: HelpCenterTipsViewStyle) {
        self.style = style
    }
    
    public func setTitle(_ title: LocalizedStylableText) {
        self.titleLabel.configureText(withLocalizedString: title,
                                      andConfiguration: LocalizedStylableTextConfiguration(
                                        font: style.titleFont,
                                        lineHeightMultiple: 0.8,
                                        lineBreakMode: .byWordWrapping))
    }
    
    public func setTitleAccessibilityIdentifier(_ identifier: String) {
        self.titleLabel.accessibilityIdentifier = identifier
    }
    
    public func setCollectionAccessibilityIdentifier(_ identifier: String) {
        self.collectionView.accessibilityIdentifier = identifier
    }
    
    @IBAction func didSelectSeeAllTips(_ sender: Any) {
        self.tipDelegate?.didSelectSeeAllTips()
    }
    
    public func showEmptyView() {
        self.stopLoading()
        self.emptyView.frame = collectionView.bounds
        self.collectionView.backgroundView = emptyView
    }
    
    public func addLoadingView() {
        self.setViewModels([])
        self.loadingView.frame = collectionView.bounds
        self.collectionView.backgroundView = loadingView
        self.loadingView.startAnimating()
    }
    
    private func stopLoading() {
        self.loadingView.stopAnimating()
        self.loadingView.removeFromSuperview()
    }
}

private extension HelpCenterTipsView {
    
    func setupView() {
        self.collectionView.reloadData()
        self.view?.backgroundColor = style.mainViewBackgroundColor
        self.titleLabel.textColor = style.titleTextColor
        self.setTitle(localized("HelpCenter_title_knowApp"))
        self.titleLabel.numberOfLines = 0
        self.collectionView.register(UINib(nibName: style.collectionViewCellIdentifier,
                                           bundle: .module),
                                     forCellWithReuseIdentifier: style.collectionViewCellIdentifier)
        self.collectionView.register(UINib(nibName: SeeAllTipsCollectionViewCell.identifier, bundle: .module),
                                     forCellWithReuseIdentifier: SeeAllTipsCollectionViewCell.identifier)
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
        self.seeAllTipsLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.seeAllTipsLabel.textColor = style.seeAllTipsColor
        self.seeAllTipsLabel.numberOfLines = 0
        self.seeAllTipsLabel.text = localized("generic_button_seeAll")
        self.seeAllTipsLabel.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.genericButtonSeeAll.rawValue
        self.seeAllTipsButtton.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.tipsBtnSeeAll.rawValue
        self.collectionView.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.tipsCarousel.rawValue
        self.seeAllTipsButtton.isHidden = !style.showAllTips
        self.seeAllTipsLabel.isHidden = !style.showAllTips
        self.layoutIfNeeded()
    }
    
    func collectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 232, height: 203)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        return layout
    }
}

extension HelpCenterTipsView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return style.numberOfSections
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section != seeAllTipsSection else {
            return 1
        }
        return self.tips.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.section != seeAllTipsSection else {
           return collectionView.dequeueReusableCell(withReuseIdentifier: SeeAllTipsCollectionViewCell.identifier, for: indexPath)
        }
        let tipCell = collectionView.dequeueReusableCell(withReuseIdentifier: style.collectionViewCellIdentifier,
                                                         for: indexPath)
        (tipCell as? HelpCenterTipCollectionViewCellProtocol)?.setViewModel(self.tips[indexPath.row])
        if addAccessibilitySuffix {
            (tipCell as? HelpCenterTipCollectionViewCellProtocol)?.setupAccessibilityIdentifiers(with: "\(indexPath.row)")
        }
        return tipCell
    }
}

extension HelpCenterTipsView: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section != seeAllTipsSection else {
            self.tipDelegate?.didSelectSeeAllTips()
            return
        }
        let viewModel = self.tips[indexPath.row]
        self.tipDelegate?.didSelectTip(viewModel)
    }
}

extension HelpCenterTipsView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return style.collectionViewInset
    }
}

extension HelpCenterTipsView: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        tipDelegate?.scrollViewDidEndDecelerating()
    }
}

public class HelpCenterTipsViewStyle {
    public var mainViewBackgroundColor: UIColor
    public var titleFont: UIFont
    public var titleTextColor: UIColor
    public var collectionViewCellIdentifier: String
    public var collectionViewBackgroundColor: UIColor
    public var collectionViewInset: UIEdgeInsets
    public var collectionViewLayout: UICollectionViewFlowLayout?
    public var titleTopSpace: CGFloat
    public var titleBottomSpace: CGFloat
    public var collectionViewBottomSpace: CGFloat
    public var numberOfSections = 2
    public var seeAllTipsColor: UIColor
    public var showAllTips: Bool
    
    public init() {
        mainViewBackgroundColor = UIColor.blueAnthracita
        titleFont = UIFont.santander(size: 20)
        titleTextColor = UIColor.white
        collectionViewCellIdentifier = "HelpCenterTipCollectionViewCell"
        collectionViewBackgroundColor = UIColor.blueAnthracita
        collectionViewInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 16)
        titleTopSpace = 17
        titleBottomSpace = 15.0
        collectionViewBottomSpace = 30.0
        seeAllTipsColor = .white
        self.showAllTips = true
    }
    
    public static func homeTipsStyle() -> HelpCenterTipsViewStyle {
        let style = HelpCenterTipsViewStyle()
        style.mainViewBackgroundColor = .white
        style.titleTextColor = .lisboaGray
        style.titleFont = .santander(size: 18.0)
        style.collectionViewBackgroundColor = .white
        style.collectionViewCellIdentifier = "GlobalSearchAdviseCollectionViewCell"
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

    public static func helpCenterTipsStyle() -> HelpCenterTipsViewStyle {
        let style = HelpCenterTipsViewStyle()
        style.mainViewBackgroundColor = .blueAnthracita
        style.titleTextColor = .white
        style.titleFont = .santander(size: 18.0)
        style.collectionViewBackgroundColor = .blueAnthracita
        style.collectionViewCellIdentifier = "GlobalSearchAdviseCollectionViewCell"
        style.titleTopSpace = 20.0
        style.titleBottomSpace = 52.0
        style.collectionViewBottomSpace = 22.0
        style.collectionViewInset = UIEdgeInsets(top: 0, left: 10, bottom: 16, right: 16)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 206, height: 195)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        style.collectionViewLayout = layout
        style.numberOfSections = 2
        style.seeAllTipsColor = .white
        style.showAllTips = true
        return style
    }

    public static func interestTipsStyle() -> HelpCenterTipsViewStyle {
        let style = HelpCenterTipsViewStyle()
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
    
    public static func homeTipsSmartStyle() -> HelpCenterTipsViewStyle {
        let style = HelpCenterTipsViewStyle.homeTipsStyle()
        style.mainViewBackgroundColor = .lightGray40
        style.collectionViewBackgroundColor = .lightGray40
        style.seeAllTipsColor = .lightGray40
        return style
    }

   public static func securityTipsStyle() -> HelpCenterTipsViewStyle {
        let style = HelpCenterTipsViewStyle.helpCenterTipsStyle()
        style.showAllTips = false
        style.numberOfSections = 1
        return style
   }
}
