//
//  FractionablePurchaseCollectionView.swift
//  Cards
//
//  Created by Ignacio González Miró on 31/5/21.
//

import UIKit
import UI
import CoreFoundationLib

protocol FractionablePurchaseCollectionViewDelegate: AnyObject {
    func didSelectTransaction(_ viewModel: FractionablePurchaseDetailViewModel)
    func scrollViewDidEndDecelerating()
    func didSelectInExpandableCollapsableButton(_ state: ResizableState)
}

public final class FractionablePurchaseCollectionView: UICollectionView {
    private let identifier = "FractionablePurchaseCollectionViewCell"
    private var layout = ZoomAndSnapFlowLayout()
    private var viewModels: [FractionablePurchaseDetailViewModel] = []
    private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    private var carouselState: ResizableState = .colapsed
    weak var fractionableDelegate: FractionablePurchaseCollectionViewDelegate?

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        self.layout.forceSizeCalculation = true
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func configView(_ viewModel: FractionablePurchaseDetailCarouselViewModel) {
        let openMovements = viewModel.financeableMovementEntityList.filter { $0.carouselState == .expanded }
        self.carouselState = openMovements.isEmpty ? .colapsed : .expanded
        self.updateTransactionViewModel(viewModel.financeableMovementEntityList, selecteViewModel: viewModel.selectedFinanceableMovementEntity)
        addLayout()
    }
    
    func updateTransactionViewModel(_ viewModel: FractionablePurchaseDetailViewModel) {
        guard let index = self.getIndexForViewModel(viewModel) else { return }
        for (idx, model) in self.viewModels.enumerated() where index != idx {
            model.carouselState = .colapsed
            UIView.performWithoutAnimation {
                self.reloadItems(at: [IndexPath(item: idx, section: 0)])
            }
        }
        let indexPath = IndexPath(item: index, section: 0)
        let cell = self.cellForItem(at: indexPath) as? FractionablePurchaseCollectionViewCell
        self.viewModels[indexPath.item] = viewModel
        cell?.configView(viewModel)
        self.setUpdateLayout()
    }
}

private extension FractionablePurchaseCollectionView {
    // MARK: Setup methods
    func setupView() {
        registerCell()
        addConstraints()
        setCollectionView()
        setAccessibilityId()
    }
    
    func registerCell() {
        let nib = UINib(nibName: identifier, bundle: Bundle.module)
        register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func addLayout() {
        let itemWidth = getProportionalItemSizeWidth()
        let itemHeight = getItemSizeHeight(.colapsed)
        self.layout.setItemSize(CGSize(width: itemWidth, height: itemHeight))
        self.layout.setMinimumLineSpacing(FractionablePurchaseDetailCarouselConstants.estimatedHeight - (2 * FractionablePurchaseDetailCarouselConstants.collapsedHeight) + 0.001) // Prevents layout from adding a new line of collapsed cells
        self.layout.setZoom(0)
        collectionViewLayout = layout
    }
    
    func getProportionalItemSizeWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width * 0.8
    }
    
    func setUpdateLayout() {
        guard let indexPath = self.layout.indexPathForCenterRect(),
              let cell = self.cellForItem(at: indexPath) as? FractionablePurchaseCollectionViewCell,
              let state = cell.setViewModel()?.carouselState else {
            return
        }
        let itemHeight = getItemSizeHeight(state)
        let itemWidth = getProportionalItemSizeWidth()
        self.collectionViewHeightConstraint.constant = itemHeight
        self.layout.setItemSize(CGSize(width: itemWidth, height: itemHeight))
        self.layoutIfNeeded()
    }
    
    func updateTransactionViewModel(_ viewModels: [FractionablePurchaseDetailViewModel], selecteViewModel: FractionablePurchaseDetailViewModel) {
        self.viewModels = viewModels
        self.reloadData()
        self.setSelectedViewModel(selecteViewModel)
    }
    
    func setSelectedViewModel(_ viewModel: FractionablePurchaseDetailViewModel) {
        guard let item = self.getIndexForViewModel(viewModel) else {
            return
        }
        let indexPath = IndexPath(item: item, section: 0)
        self.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
        self.setUpdateLayout()
        self.layout.invalidateLayout()
    }

    func getItemSizeHeight(_ state: ResizableState) -> CGFloat {
        return state == .colapsed
            ? FractionablePurchaseDetailCarouselConstants.collapsedHeight
            : FractionablePurchaseDetailCarouselConstants.estimatedHeight
    }
    
    func addConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        let itemHeight = getItemSizeHeight(.colapsed)
        self.collectionViewHeightConstraint = self.heightAnchor.constraint(equalToConstant: itemHeight)
        self.collectionViewHeightConstraint.isActive = true
    }
    
    func setCollectionView() {
        backgroundColor = UIColor.skyGray
        decelerationRate = .fast
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        delegate = self
        dataSource = self
    }
    
    func setAccessibilityId() {
        accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.collectionView
    }
    
    func getIndexForViewModel(_ viewModel: FractionablePurchaseDetailViewModel) -> Int? {
        guard viewModel.financeableMovementEntity.identifier != nil else { return nil }
        let index = self.viewModels.firstIndex(where: {
                return $0.financeableMovementEntity.identifier == viewModel.financeableMovementEntity.identifier
            })
        return index
    }
}

extension FractionablePurchaseCollectionView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? FractionablePurchaseCollectionViewCell else {
            return UICollectionViewCell()
        }
        let viewModel = self.viewModels[indexPath.item]
        cell.delegate = self
        cell.tag = indexPath.item
        cell.configView(viewModel)
        return cell
    }
}

extension FractionablePurchaseCollectionView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = getItemSizeHeight(viewModels[indexPath.item].carouselState)
        let widht: CGFloat = getProportionalItemSizeWidth()
        return CGSize(width: widht, height: height)
    }
}

extension FractionablePurchaseCollectionView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let indexPath = self.layout.indexPathForCenterRect() else {
            return
        }
        let viewModel = self.viewModels[indexPath.item]
        fractionableDelegate?.scrollViewDidEndDecelerating()
        fractionableDelegate?.didSelectTransaction(viewModel)
    }
}

extension FractionablePurchaseCollectionView: FractionablePurchaseCollectionViewCellDelegate {
    func resizeCell(_ model: FractionablePurchaseDetailViewModel) {
        fractionableDelegate?.didSelectInExpandableCollapsableButton(model.carouselState)
    }
}
