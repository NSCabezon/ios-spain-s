//
//  TransactionCollectoinView.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 12/4/19.
//

import UIKit
import CoreFoundationLib
import UI

protocol CardTransactionCollectoinViewCellDelegate: AnyObject {
    func didSelectTransactionViewModel(_ viewModel: OldCardTransactionDetailViewModel)
    func didSelectFractionate()
    func didSelectOffer(viewModel: OldCardTransactionDetailViewModel)
}

final class OldCardTransactionCollectoinView: UICollectionView {
    private let identifier = "OldCardTransactionCollectionViewCell"
    private var layout = ZoomAndSnapFlowLayout()
    private var viewModels: [OldCardTransactionDetailViewModel] = []
    private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    public weak var transactionDelegate: CardTransactionCollectoinViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        self.layout.forceSizeCalculation = true
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.registerCell()
        self.addLayout()
        self.addConstraints()
        self.backgroundColor = UIColor.skyGray
        self.decelerationRate = .fast
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.delegate = self
        self.dataSource = self
    }
    
    private func addLayout() {
        let itemWidth = getProportionalItemSizeWidth()
        self.layout.setItemSize(CGSize(width: itemWidth, height: ExpandableConfig.estimatedExpandedHeight))
        self.layout.setMinimumLineSpacing(16)
        self.layout.setZoom(0)
        self.collectionViewLayout = layout
    }
    
    private func registerCell() {
        let nib = UINib(nibName: identifier, bundle: Bundle.module)
        self.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    private func getProportionalItemSizeWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width * 0.80
    }
    
    private func setUpdateLayout() {
        guard let indexPath = self.layout.indexPathForCenterRect() else { return }
        let cell = self.cellForItem(at: indexPath) as? OldCardTransactionCollectionViewCell
        self.collectionViewHeightConstraint.constant = cell?.getExpandedHeight() ?? ExpandableConfig.estimatedHeight
        self.layoutIfNeeded()
    }
    
    func updateTransactionViewModel(_ viewModels: [OldCardTransactionDetailViewModel], selecteViewModel: OldCardTransactionDetailViewModel) {
        self.viewModels = viewModels
        self.reloadData()
        self.setSelectedViewModel(selecteViewModel)
    }
    
    func updateTransactionViewModel(_ viewModel: OldCardTransactionDetailViewModel) {
        guard let index = self.getIndexForViewModel(viewModel) else { return }
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.cellForItem(at: indexPath) as? OldCardTransactionCollectionViewCell
        self.viewModels[indexPath.item] = viewModel
        cell?.configure(viewModel, showFractionateButton: true)
        self.setUpdateLayout()
    }
    
    public func setSelectedViewModel(_ viewModel: OldCardTransactionDetailViewModel) {
        guard let item = self.getIndexForViewModel(viewModel) else { return }
        let indexPath = IndexPath(item: item, section: 0)
        self.layoutIfNeeded()
        self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.setUpdateLayout()
        self.layout.invalidateLayout()
    }
    
    private func getIndexForViewModel(_ viewModel: OldCardTransactionDetailViewModel) -> Int? {
        let index = self.viewModels.firstIndex(where: { return $0 == viewModel})
        return index
    }
    
    private func addConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.collectionViewHeightConstraint =
            self.heightAnchor.constraint(equalToConstant: ExpandableConfig.estimatedHeight)
        self.collectionViewHeightConstraint?.isActive = true
    }
}

extension OldCardTransactionCollectoinView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? OldCardTransactionCollectionViewCell
        let viewModel = self.viewModels[indexPath.row]
        cell?.delegate = self
        cell?.configure(viewModel)
        return cell ?? UICollectionViewCell()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let indexPath = self.layout.indexPathForCenterRect() else { return }
        let viewModel = self.viewModels[indexPath.item]
        self.transactionDelegate?.didSelectTransactionViewModel(viewModel)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false 
    }
}

extension OldCardTransactionCollectoinView: TransactionCollectionViewCellDelegate {
    func didTapOnFractionate() {
        self.transactionDelegate?.didSelectFractionate()
    }
    
    func didSelectOffer(viewModel: OldCardTransactionDetailViewModel) {
        self.transactionDelegate?.didSelectOffer(viewModel: viewModel)
    }
    
    func resizeCell() {
        self.setUpdateLayout()
    }
}
