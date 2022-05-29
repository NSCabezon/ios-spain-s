//
//  FractionatedPurchasesCollectionViewCell.swift
//  Menu
//
//  Created by Ignacio González Miró on 6/7/21.
//

import UIKit
import UI
import CoreFoundationLib

final class FractionatedPurchasesCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var baseView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    
    static let itemIdentifier = "FractionatedPurchasesCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func configView(_ viewModel: FractionatePurchasesCarouselViewModel) {
        removeArrangedSubviewsIfNeeded()
        addDetailView(viewModel)
        handleFeeDetailView(viewModel.feeDetailViewModel)
    }
}

private extension FractionatedPurchasesCollectionViewCell {
    func setupView() {
        layer.masksToBounds = false
        clipsToBounds = false
        backgroundColor = .clear
        drawShadow(offset: (x: 1, y: 2), color: .shadesWhite, radius: 2)
        setBaseView()
    }
    
    func setBaseView() {
        baseView.backgroundColor = .white
        baseView.roundCorners(corners: [.allCorners], radius: 5)
        baseView.drawBorder(cornerRadius: 5, color: .lightSkyBlue, width: 1)
        baseView.accessibilityIdentifier = AccessibilityFractionatedPurchasesCarouselItem.itemCellBaseView
    }
    
    // MARK: Custom SubViews
    func addDetailView(_ viewModel: FractionatePurchasesCarouselViewModel) {
        let view = FractionatedPurchaseCarouselItemDetailView()
        view.configView(viewModel)
        self.stackView.addArrangedSubview(view)
    }
    
    func addFeeDetailView(_ viewModel: FractionatePurchasesCarouselDetailViewModel) {
        let view = FractionatedPurchaseCarouselItemFeeDetailView()
        view.configView(viewModel)
        self.stackView.addArrangedSubview(view)
    }
    
    func removeArrangedSubviewsIfNeeded() {
        self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    func handleFeeDetailView(_ viewModel: FractionatePurchasesCarouselDetailViewModel?) {
        guard let detailViewModel = viewModel else {
            return
        }
        addFeeDetailView(detailViewModel)
    }
}
