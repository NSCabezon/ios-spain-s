import UIKit
import UI

public final class DetailGraphAnnualItemView: UICollectionViewCell {
    let cellIdentifier = "DetailGraphMonthlyItemView"
    static let minimumAverageViewBottomValue: CGFloat = 38
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var averageView: DottedLineView!
    @IBOutlet private weak var averageViewBottomContraint: NSLayoutConstraint!
    
    var viewModel: CardSubscriptionDetailYearViewModel?
    var isLastYear: Bool = false
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        self.averageViewBottomContraint.constant = DetailGraphAnnualItemView.minimumAverageViewBottomValue
    }
    
    func configView(_ viewModel: CardSubscriptionDetailYearViewModel, isLastYear: Bool) {
        self.viewModel = viewModel
        self.isLastYear = isLastYear
        self.averageViewBottomContraint.constant = DetailGraphAnnualItemView.minimumAverageViewBottomValue + (viewModel.maximumAverageRatio * DetailGraphConstants.maximunValue)
        collectionView.reloadData()
    }
}

extension DetailGraphAnnualItemView: UICollectionViewDelegate {
    
}

extension DetailGraphAnnualItemView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.monthsViewModel.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? DetailGraphMonthlyItemView,
            let viewModel = viewModel else {
            return UICollectionViewCell()
        }
        cell.configView(viewModel.monthsViewModel[indexPath.row], isLastMonth: (viewModel.monthsViewModel.count - 1 == indexPath.row) && isLastYear)
        return cell
    }
}

extension DetailGraphAnnualItemView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let constantWeight = 68
        let constantHeight = 196
        return CGSize(width: CGFloat(constantWeight),
                      height: CGFloat(constantHeight))
    }
}

private extension DetailGraphAnnualItemView {
    func setupView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        self.averageView.strokeColor = .purple
        self.averageView.lineDashPattern = [2, 4]
        self.averageView.orientation = .horizontal
        self.averageView.lineWidth = 2.0
        registerCell()
    }
    
    func registerCell() {
        let nib = UINib(nibName: cellIdentifier, bundle: Bundle.module)
        self.collectionView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
    }
}
