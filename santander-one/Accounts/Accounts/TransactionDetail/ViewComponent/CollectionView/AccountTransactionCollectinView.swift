//
//  CardTransactionCollectoinView.swift
//  Account
//
//  Created by Juan Carlos López Robles on 12/5/19.
//

import UIKit
import UI

protocol AccountTransactionCollectinViewDelegate: AnyObject {
    func didSelectTransaction(_ transaction: AccountTransactionDetailViewModel)
    func didSelectEasyPay(_ transaction: AccountTransactionDetailViewModel)
    func didSelectOffer(viewModel: AccountTransactionDetailViewModel)
    func scrollViewDidEndDecelerating()
}

class AccountTransactionCollectinView: UICollectionView {
    private let identifier = "AccountTransactionCollectionViewCell"
    private var layout = ZoomAndSnapFlowLayout()
    private var viewModels: [AccountTransactionDetailViewModel] = []
    private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    private let estimatedHeight = AccountTransactionCollectionViewCell.Constants.estimatedHeight
    private let collapsedHeight = AccountTransactionCollectionViewCell.Constants.collapsedHeight
    public weak var transactionDelegate: AccountTransactionCollectinViewDelegate?

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
        self.layout.setItemSize(CGSize(width: itemWidth, height: estimatedHeight))
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
        let cell = self.cellForItem(at: indexPath) as? AccountTransactionCollectionViewCell
        self.collectionViewHeightConstraint.constant = cell?.getHeightForState() ?? estimatedHeight
        self.layoutIfNeeded()
    }
    
    func updateTransactionViewModel(_ viewModels: [AccountTransactionDetailViewModel], selecteViewModel: AccountTransactionDetailViewModel) {
        self.viewModels = viewModels
        self.reloadData()
        self.setSelectedViewModel(selecteViewModel)
    }
    
    func updateTransactionViewModel(_ viewModel: AccountTransactionDetailViewModel) {
        guard let index = self.getIndexForViewModel(viewModel) else { return }
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.cellForItem(at: indexPath) as? AccountTransactionCollectionViewCell
        self.viewModels[indexPath.item] = viewModel
        cell?.configure(viewModel)
        self.setUpdateLayout()
    }
    
    public func setSelectedViewModel(_ viewModel: AccountTransactionDetailViewModel) {
        guard let item = self.getIndexForViewModel(viewModel) else { return }
        let indexPath = IndexPath(item: item, section: 0)
        self.layoutIfNeeded()
        self.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        self.setUpdateLayout()
        self.layout.invalidateLayout()
    }
    
    private func getIndexForViewModel(_ viewModel: AccountTransactionDetailViewModel) -> Int? {
        let index = self.viewModels.firstIndex(where: { return $0 == viewModel})
        return index
    }
    
    private func addConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.collectionViewHeightConstraint =
            self.heightAnchor.constraint(equalToConstant: collapsedHeight)
        self.collectionViewHeightConstraint?.isActive = true
    }
}

extension AccountTransactionCollectinView: ResizableStateDelegate {
    func didStateChange(_ state: ResizableState) {
        self.setUpdateLayout()
        self.layout.invalidateLayout()
    }
}

extension AccountTransactionCollectinView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? AccountTransactionCollectionViewCell
        let viewModel = self.viewModels[indexPath.row]
        cell?.resizableDelegate = self
        cell?.delegate = self
        cell?.configure(viewModel)
        return cell ?? UICollectionViewCell()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let indexPath = self.layout.indexPathForCenterRect() else { return }
        let viewModel = self.viewModels[indexPath.item]
        self.setUpdateLayout()
        self.transactionDelegate?.didSelectTransaction(viewModel)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension AccountTransactionCollectinView: TransactionCollectionViewCellDelegate {
    func didSelectEasyPay(viewModel: AccountTransactionDetailViewModel) {
        self.transactionDelegate?.didSelectEasyPay(viewModel)
    }
    
    func didSelectOffer(viewModel: AccountTransactionDetailViewModel) {
        self.transactionDelegate?.didSelectOffer(viewModel: viewModel)
    }
    
    func resizeCell() {
        self.setUpdateLayout()
    }
}

extension AccountTransactionCollectinView: UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        transactionDelegate?.scrollViewDidEndDecelerating()
    }
}
