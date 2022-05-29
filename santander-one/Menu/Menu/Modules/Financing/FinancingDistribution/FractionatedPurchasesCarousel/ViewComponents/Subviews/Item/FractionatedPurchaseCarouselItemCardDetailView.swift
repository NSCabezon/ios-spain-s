//
//  FractionatedPurchaseCarouselItemCardDetailView.swift
//  Menu
//
//  Created by Ignacio González Miró on 6/7/21.
//

import UIKit
import UI
import CoreFoundationLib

final class FractionatedPurchaseCarouselItemCardDetailView: XibView {
    @IBOutlet private weak var cardImageView: UIImageView!
    @IBOutlet private weak var cardTitleLabel: UILabel!

    private let defaultImage = Assets.image(named: "defaultCard")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: FractionatePurchasesCarouselViewModel) {
        handleCardImage(viewModel)
        cardTitleLabel.text = viewModel.cardAliasAndNumber
    }
}

private extension FractionatedPurchaseCarouselItemCardDetailView {
    func setupView() {
        backgroundColor = .clear
        setTitleLabel()
        setAccessibilityIds()
    }
    
    func handleCardImage(_ viewModel: FractionatePurchasesCarouselViewModel) {
        if let imageUrl = viewModel.cardImageUrl {
            cardImageView.loadImage(urlString: imageUrl,
                                    placeholder: defaultImage,
                                    completion: nil)
        } else {
            cardImageView.image = defaultImage
        }
    }
    
    func setTitleLabel() {
        cardTitleLabel.font = .santander(family: .text, type: .regular, size: 14)
        cardTitleLabel.textAlignment = .left
        cardTitleLabel.textColor = .brownishGray
        cardTitleLabel.numberOfLines = 1
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityFractionatedPurchasesCarouselItem.itemCellCardDetailBaseView
        cardImageView.accessibilityIdentifier = AccessibilityFractionatedPurchasesCarouselItem.itemCellCardDetailCardImageView
        cardTitleLabel.accessibilityIdentifier = AccessibilityFractionatedPurchasesCarouselItem.itemCellCardDetailCardTitleLabel
    }
}
