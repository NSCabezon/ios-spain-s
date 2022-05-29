//
//  FractionatedPurchasesCollectionView.swift
//  Menu
//
//  Created by Ignacio González Miró on 6/7/21.
//

import UIKit
import UI

struct FractionatedPurchasesCollectionViewConstants {
    static let carouselItemSize = CGSize(width: 345, height: 219)
    static let carouselItemSeeMoreSize = CGSize(width: 168, height: 219)
    static let defaultCarouselHeight: CGFloat = 284
}

public protocol FractionatedPurchasesCollectionViewDelegate: AnyObject {
    func updatedFractionatedPurchasesCarouselHeight(_ height: CGFloat)
    func didTapInFractionatedPurchase(_ viewModel: FractionatePurchasesCarouselViewModel)
    func didTapInSeeMoreFractionatedPurchases()
    func didSwipe()
}

public final class FractionatedPurchasesCollectionView: UICollectionView {
    private let layout: ZoomAndSnapFlowLayout = ZoomAndSnapFlowLayout()
    private var viewModels: [FractionatePurchasesCarouselViewModel] = []
    weak var fractionatedPurchaseDelegate: FractionatedPurchasesCollectionViewDelegate?
    typealias Constants = FractionatedPurchasesCollectionViewConstants
    
    init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModels(_ viewModels: [FractionatePurchasesCarouselViewModel]) {
        self.viewModels = viewModels
        reloadData()
        updateCarouselHeight()
    }
}

private extension FractionatedPurchasesCollectionView {
    func setupView() {
        registerCell()
        addLayout()
        setCollectionView()
    }
    
    func registerCell() {
        let itemNib = UINib(nibName: FractionatedPurchasesCollectionViewCell.itemIdentifier, bundle: Bundle.module)
        register(itemNib, forCellWithReuseIdentifier: FractionatedPurchasesCollectionViewCell.itemIdentifier)
        let loadMoreNib = UINib(nibName: FractionatedPurchasesSeeMoreCollectionViewCell.loadMoreIdentifier, bundle: Bundle.module)
        register(loadMoreNib, forCellWithReuseIdentifier: FractionatedPurchasesSeeMoreCollectionViewCell.loadMoreIdentifier)
    }
    
    func addLayout() {
        layout.setItemSize(Constants.carouselItemSize)
        layout.setMinimumLineSpacing(7)
        layout.setZoom(0)
        collectionViewLayout = layout
    }
    
    func setCollectionView() {
        decelerationRate = .fast
        backgroundColor = .white
        showsHorizontalScrollIndicator = false
        delegate = self
        dataSource = self
    }
    
    func updateCarouselHeight() {
        fractionatedPurchaseDelegate?.updatedFractionatedPurchasesCarouselHeight(Constants.defaultCarouselHeight)
    }
}

extension FractionatedPurchasesCollectionView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = viewModels[indexPath.row]
        switch viewModel.carouselItemType {
        case .item:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FractionatedPurchasesCollectionViewCell.itemIdentifier, for: indexPath) as? FractionatedPurchasesCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configView(viewModel)
            return cell
        case .seeMoreItems:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FractionatedPurchasesSeeMoreCollectionViewCell.loadMoreIdentifier, for: indexPath) as? FractionatedPurchasesSeeMoreCollectionViewCell else {
                return UICollectionViewCell()
            }
            return cell
        }
    }
}

extension FractionatedPurchasesCollectionView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewModel = viewModels[indexPath.row]
        switch viewModel.carouselItemType {
        case .item:
            fractionatedPurchaseDelegate?.didTapInFractionatedPurchase(viewModel)
        case .seeMoreItems:
            fractionatedPurchaseDelegate?.didTapInSeeMoreFractionatedPurchases()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        fractionatedPurchaseDelegate?.didSwipe()
    }
}

extension FractionatedPurchasesCollectionView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = viewModels[indexPath.row]
        switch viewModel.carouselItemType {
        case .item:
            return Constants.carouselItemSize
        case .seeMoreItems:
            return Constants.carouselItemSeeMoreSize
        }
    }
}
