import UIKit
import UI
import CoreFoundationLib

public final class CardSubscriptionDetailGraphCollectionView: XibView {
    let cellIdentifier = "DetailGraphAnnualItemView"
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var emptyTitleLabel: UILabel!
    
    var viewModel: [CardSubscriptionDetailYearViewModel] = []
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    func configView(_ viewModel: [CardSubscriptionDetailYearViewModel], type: CardSubscriptionGraphType) {
        self.viewModel = viewModel
        collectionView.reloadData()
        emptyTitleLabel.isHidden = type != .empty
        collectionView.alpha = type == .empty ? 0.5 : 1
    }
}

extension CardSubscriptionDetailGraphCollectionView: UICollectionViewDelegate {
    
}

extension CardSubscriptionDetailGraphCollectionView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? DetailGraphAnnualItemView else {
            return UICollectionViewCell()
        }
        let model = self.viewModel[indexPath.row]
        cell.configView(model, isLastYear: viewModel.count - 1 == indexPath.row)
        return cell
    }
}

extension CardSubscriptionDetailGraphCollectionView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let constantWeight = viewModel[indexPath.row].monthsViewModel.count * (68)
        let constantHeight = 196
        return CGSize(width: CGFloat(constantWeight),
                      height: CGFloat(constantHeight))
    }
}

private extension CardSubscriptionDetailGraphCollectionView {
    
    func setupView() {
        setTitleLabel()
        setCollectionView()
        backgroundColor = .skyGray
    }
    
    func setTitleLabel() {
        let textConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14), lineHeightMultiple: 0.75)
        titleLabel.configureText(withKey: "m4m_label_evolutionAndAnalysis", andConfiguration: textConfiguration)
    }
    
    func setCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        registerCell()
        collectionView.semanticContentAttribute = .forceRightToLeft
        setEmptyTitleLabel()
    }
    
    func registerCell() {
        let nib = UINib(nibName: cellIdentifier, bundle: Bundle.module)
        self.collectionView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    func setEmptyTitleLabel() {
        let textConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .regular, size: 16), lineHeightMultiple: 0.75)
        emptyTitleLabel.configureText(withKey: "generic_label_emptyError", andConfiguration: textConfiguration)
        emptyTitleLabel.numberOfLines = 0
        emptyTitleLabel.tintColor = .lisboaGray
        emptyTitleLabel.textAlignment = .center
    }
}
