import UIKit
import CoreFoundationLib

protocol HomeTipsTableViewCellDelegate: AnyObject {
    func didSelectTip(_ viewModel: HomeTipsViewModel)
    func didSelectAll(_ indexPath: IndexPath)
    func scrollViewDidEndDecelerating()
}

class HomeTipsTableViewCell: UITableViewCell {
    static let cellIdentifier = "HomeTipsTableViewCell"
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var selectAllButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var tipDelegate: HomeTipsTableViewCellDelegate?
    private var tips: [HomeTipsViewModel] = []
    private let style = HomeTipsViewStyle()
    private var indexPath: IndexPath?
    private var position: CGPoint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel?.text = ""
        self.selectAllButton.setTitle("", for: .normal)
        self.collectionView.contentOffset = position ?? .zero
    }

    func setViewModels(viewModel: HomeTipsCellViewModel, indexPath: IndexPath) {
        self.tips = viewModel.content
        self.showTitle(viewModel.title)
        self.selectAllButton.setTitle(localized("generic_button_seeAll"), for: .normal)
        self.indexPath = indexPath
        self.collectionView.reloadData()
        self.collectionView.contentOffset = viewModel.position ?? .zero
    }

    @IBAction func selectAllPressedButton(_ sender: UIButton) {
        guard let indexPath = self.indexPath else { return }
        self.tipDelegate?.didSelectAll(indexPath)
    }

    private func showTitle(_ title: String) {
        let numberTips = " (" + "\(tips.count)" + ")"
        let completeTitle = title + numberTips
        let numberTipsLocalizeStyle: LocalizedStylableText = localized(completeTitle)
        self.titleLabel.configureText(withLocalizedString: numberTipsLocalizeStyle)
        self.titleLabel.accessibilityIdentifier = AccessibilityHomeTips.titleLabel.rawValue
    }
}

private extension HomeTipsTableViewCell {
    func setupView() {
        self.backgroundColor = style.mainViewBackgroundColor
        self.titleLabel.font = style.titleFont
        self.titleLabel.textColor = style.titleTextColor
        self.selectAllButton.setTitleColor(style.buttonTextColor, for: .normal)
        self.selectAllButton.titleLabel?.font = style.buttonFont
        self.selectAllButton.accessibilityIdentifier = AccessibilityHomeTips.genericButtonSeeAll.rawValue
        self.collectionView.register(UINib(nibName: style.collectionViewCellIdentifier,
                                           bundle: .module),
                                     forCellWithReuseIdentifier: style.collectionViewCellIdentifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.setCollectionViewLayout(self.collectionViewLayout(), animated: false)
        self.collectionView.backgroundColor = style.collectionViewBackgroundColor
        self.collectionView.contentInset = style.collectionViewInset
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.accessibilityIdentifier = AccessibilityHomeTips.tipsCarousel.rawValue
        self.collectionView.reloadData()
    }
    
    func collectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 224, height: 214)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return layout
    }
}

extension HomeTipsTableViewCell: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tips.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tipCell = collectionView.dequeueReusableCell(withReuseIdentifier: style.collectionViewCellIdentifier, for: indexPath)
        (tipCell as? HomeTipsCollectionViewCellProtocol)?.setViewModel(self.tips[indexPath.row])
        return tipCell
    }
}

extension HomeTipsTableViewCell: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewModel = self.tips[indexPath.row]
        self.tipDelegate?.didSelectTip(viewModel)
    }
}

extension HomeTipsTableViewCell: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        tipDelegate?.scrollViewDidEndDecelerating()
    }
}

class HomeTipsViewStyle {
    let mainViewBackgroundColor: UIColor
    let titleFont: UIFont
    let titleTextColor: UIColor
    let buttonFont: UIFont
    let buttonTextColor: UIColor
    
    let collectionViewCellIdentifier: String
    let collectionViewBackgroundColor: UIColor
    let collectionViewInset: UIEdgeInsets
    
    init() {
        mainViewBackgroundColor = .white
        titleFont = .santander(family: .text, type: .regular, size: 18.0)
        titleTextColor = .lisboaGray
        buttonFont = .santander(family: .text, type: .regular, size: 16.0)
        buttonTextColor = .darkTorquoise
        collectionViewCellIdentifier = "HomeTipsCollectionViewCell"
        collectionViewBackgroundColor = .white
        collectionViewInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 16)
    }
}
