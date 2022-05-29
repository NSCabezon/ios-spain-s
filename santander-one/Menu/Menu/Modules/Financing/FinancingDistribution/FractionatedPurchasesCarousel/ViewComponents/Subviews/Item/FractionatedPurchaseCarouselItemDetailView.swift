//
//  FractionatedPurchaseCarouselItemDetailView.swift
//  Menu
//
//  Created by Ignacio González Miró on 6/7/21.
//

import UIKit
import UI
import CoreFoundationLib

final class FractionatedPurchaseCarouselItemDetailView: XibView {
    @IBOutlet private weak var fractionableMovementView: FractionableMovementView!
    @IBOutlet private weak var cardDetailView: FractionatedPurchaseCarouselItemCardDetailView!
    @IBOutlet private weak var bottomSeparatorView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: FractionatePurchasesCarouselViewModel) {
        guard let movementViewModel = viewModel.movementViewModel else {
            return
        }
        fractionableMovementView.setInfo(movementViewModel, delegate: nil)
        cardDetailView.configView(viewModel)
    }
}

private extension FractionatedPurchaseCarouselItemDetailView {
    func setupView() {
        backgroundColor = .clear
        bottomSeparatorView.backgroundColor = .mediumSkyGray
        accessibilityIdentifier = AccessibilityFractionatedPurchasesCarouselItem.itemCellDetailBaseView
    }
}
