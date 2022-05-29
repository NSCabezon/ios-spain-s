//
//  FractionatedPurchasesView.swift
//  Pods
//
//  Created by Ignacio González Miró on 6/7/21.
//

import UIKit
import UI
import CoreFoundationLib

public protocol FractionatedPurchasesCarouselViewDelegate: AnyObject {
    func updatedFractionatedPurchasesCarouselHeight(_ height: CGFloat)
    func didTapInFractionatedPurchase(_ viewModel: FractionatePurchasesCarouselViewModel)
    func didTapInSeeMoreFractionatedPurchases()
    func didSwipeCollectionView()
}

public final class FractionatedPurchasesCarouselView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var collectionView: FractionatedPurchasesCollectionView!

    private let loadingView = FractionatedPurchaseCarouselLoadingView()
    private let emptyView = FractionatedPurchaseCarouselEmptyView()
    weak var delegate: FractionatedPurchasesCarouselViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModels: [FractionatePurchasesCarouselViewModel], numOfItems: Int) {
        stopLoading()
        collectionView.backgroundView = nil
        setTitleLabel(numOfItems)
        collectionView.setViewModels(viewModels)
    }
    
    func showEmptyView() {
        setEmptyView()
    }
    
    func showLoadingView() {
        setLoadingView()
    }
}

private extension FractionatedPurchasesCarouselView {
    func setupView() {
        backgroundColor = .clear
        isHidden = false
        collectionView.fractionatedPurchaseDelegate = self
        setAccessibilityIds()
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityFractionatedPurchasesCarousel.carouselBaseView
        titleLabel.accessibilityIdentifier = AccessibilityFractionatedPurchasesCarousel.carouselTitleLabel
        collectionView.accessibilityIdentifier = AccessibilityFractionatedPurchasesCarousel.carouselCollectionView
    }
    
    func setTitleLabel(_ numOfItems: Int) {
        let stringPlaceholder = [StringPlaceholder(.number, String(numOfItems))]
        let localizedString = localized("fractionatePurchases_title_myFractionatePurchases", stringPlaceholder)
        let configuration = LocalizedStylableTextConfiguration(font: .santander(size: 22), alignment: .left, lineBreakMode: .none)
        titleLabel.configureText(withLocalizedString: localizedString, andConfiguration: configuration)
        titleLabel.textColor = .lisboaGray
        titleLabel.numberOfLines = 1
    }
    
    func setEmptyView() {
        setTitleLabel(.zero)
        stopLoading()
        emptyView.frame = collectionView.bounds
        collectionView.backgroundView = emptyView
    }
    
    func setLoadingView() {
        setTitleLabel(.zero)
        collectionView.setViewModels([])
        loadingView.frame = collectionView.bounds
        collectionView.backgroundView = loadingView
        loadingView.startAnimating()
    }
    
    func stopLoading() {
        self.loadingView.stopAnimating()
        loadingView.removeFromSuperview()
    }
}

extension FractionatedPurchasesCarouselView: FractionatedPurchasesCollectionViewDelegate {
    public func updatedFractionatedPurchasesCarouselHeight(_ height: CGFloat) {
        delegate?.updatedFractionatedPurchasesCarouselHeight(height)
    }
    
    public func didTapInFractionatedPurchase(_ viewModel: FractionatePurchasesCarouselViewModel) {
        delegate?.didTapInFractionatedPurchase(viewModel)
    }
    
    public func didTapInSeeMoreFractionatedPurchases() {
        delegate?.didTapInSeeMoreFractionatedPurchases()
    }
    
    public func didSwipe() {
        delegate?.didSwipeCollectionView()
    }
}
