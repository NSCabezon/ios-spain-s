//
//  LoanTransactionCollectionView.swift
//  Account
//
//  Created by Ernesto Fernandez Calles on 24/8/21.
//

import UIKit
import CoreFoundationLib
import UI
import OpenCombine

final class LoanTransactionCollectionView: UICollectionView {
    private let identifier = "LoanTransactionCollectionViewCell"
    private var layout = ZoomAndSnapFlowLayout()
    private var viewModels: [LoanTransactionDetail] = []
    private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    let didSelectTransactionSubject = PassthroughSubject<LoanTransactionDetail, Never>()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        self.layout.forceSizeCalculation = true
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setTransactionDetailList(_ detailList: [LoanTransactionDetail]) {
        self.viewModels = detailList
        self.reloadData()
    }
    
    func updateTransactionDetailList(_ detailList: [LoanTransactionDetail], selectedViewModel: LoanTransactionDetail) {
        self.setTransactionDetailList(detailList)
        self.setSelectedViewModel(selectedViewModel)
    }
    
    func updateTransactionDetail(_ detail: LoanTransactionDetail) {
        guard let index = self.getIndexForViewModel(detail) else { return }
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.cellForItem(at: indexPath) as? LoanTransactionCollectionViewCell
        self.viewModels[indexPath.item] = detail
        cell?.configure(detail)
        if let height = cell?.contentViewHeight() {
            self.collectionViewHeightConstraint.constant = height
        }
    }
    
    func setSelectedViewModel(_ viewModel: LoanTransactionDetail) {
        guard let item = self.getIndexForViewModel(viewModel) else { return }
        let indexPath = IndexPath(item: item, section: 0)
        self.layoutIfNeeded()
        self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        self.layout.invalidateLayout()
    }
    
    func focusedTransactionDetail() -> LoanTransactionDetail? {
        guard let indexPath = self.layout.indexPathForCenterRect() else { return nil }
        return self.viewModels[indexPath.item]
    }
    
    func focusedTransactionPublisher() -> AnyPublisher<LoanTransactionDetail?, Never> {
        return Just(focusedTransactionDetail())
            .eraseToAnyPublisher()
    }
}

private extension LoanTransactionCollectionView {
    func setupView() {
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
    
    func addLayout() {
        let itemWidth = getProportionalItemSizeWidth()
        self.layout.setItemSize(CGSize(width: itemWidth, height: ExpandableConfig.estimatedHeight))
        self.layout.setMinimumLineSpacing(16)
        self.layout.setZoom(0)
        self.collectionViewLayout = layout
    }
    
    func registerCell() {
        let nib = UINib(nibName: identifier, bundle: Bundle.module)
        self.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func getProportionalItemSizeWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width * 0.80
    }
    
    func getIndexForViewModel(_ viewModel: LoanTransactionDetail) -> Int? {
        return self.viewModels.firstIndex(where: { return $0 == viewModel})
    }
    
    func addConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.collectionViewHeightConstraint =
            self.heightAnchor.constraint(equalToConstant: ExpandableConfig.estimatedHeight)
        self.collectionViewHeightConstraint?.isActive = true
    }
}

extension LoanTransactionCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? LoanTransactionCollectionViewCell
        let viewModel = self.viewModels[indexPath.row]
        cell?.configure(viewModel)
        let containerId = "\(AccessibilityIDLoansTransactionsDetail.itemContainer.rawValue)\(indexPath.row + 1)"
        cell?.setContainerAccessibilityId(containerId)
        if let height = cell?.contentViewHeight() {
            self.collectionViewHeightConstraint.constant = height
        }
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let indexPath = self.layout.indexPathForCenterRect() else { return }
        let viewModel = self.viewModels[indexPath.item]
        self.didSelectTransactionSubject.send(viewModel)
    }
}

private struct ExpandableConfig {
    static let estimatedHeight: CGFloat = 400
}

final class OldLoanTransactionCollectionView: UICollectionView {
    private let identifier = "OldLoanTransactionCollectionViewCell"
    private var layout = ZoomAndSnapFlowLayout()
    private var viewModels: [OldLoanTransactionDetailViewModel] = []
    private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        self.layout.forceSizeCalculation = true
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func updateTransactionViewModel(_ viewModels: [OldLoanTransactionDetailViewModel], selectedViewModel: OldLoanTransactionDetailViewModel) {
        self.viewModels = viewModels
        self.reloadData()
        self.setSelectedViewModel(selectedViewModel)
    }
    
    func updateTransactionViewModel(_ viewModel: OldLoanTransactionDetailViewModel) {
        guard let index = self.getIndexForViewModel(viewModel) else { return }
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.cellForItem(at: indexPath) as? OldLoanTransactionCollectionViewCell
        self.viewModels[indexPath.item] = viewModel
        cell?.configure(viewModel)
    }
    
    public func setSelectedViewModel(_ viewModel: OldLoanTransactionDetailViewModel) {
        guard let item = self.getIndexForViewModel(viewModel) else { return }
        let indexPath = IndexPath(item: item, section: 0)
        self.layoutIfNeeded()
        self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.layout.invalidateLayout()
    }
    
}

private extension OldLoanTransactionCollectionView {
    func setupView() {
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
    
    func addLayout() {
        let itemWidth = getProportionalItemSizeWidth()
        self.layout.setItemSize(CGSize(width: itemWidth, height: ExpandableConfig.estimatedHeight))
        self.layout.setMinimumLineSpacing(16)
        self.layout.setZoom(0)
        self.collectionViewLayout = layout
    }
    
    func registerCell() {
        let nib = UINib(nibName: identifier, bundle: Bundle.module)
        self.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func getProportionalItemSizeWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width * 0.80
    }
    
    func getIndexForViewModel(_ viewModel: OldLoanTransactionDetailViewModel) -> Int? {
        let index = self.viewModels.firstIndex(where: { return $0 == viewModel})
        return index
    }
    
    func addConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.collectionViewHeightConstraint =
            self.heightAnchor.constraint(equalToConstant: ExpandableConfig.estimatedHeight)
        self.collectionViewHeightConstraint?.isActive = true
    }
}

extension OldLoanTransactionCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? OldLoanTransactionCollectionViewCell
        let viewModel = self.viewModels[indexPath.row]
        cell?.configure(viewModel)
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}
