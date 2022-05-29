//
//  SingleCardHeaderView.swift
//  Cards
//
//  Created by Laura González on 06/10/2020.
//

import Foundation
import UI
import CoreFoundationLib

final class SingleCardHeaderView: UIDesignableView {
    
    @IBOutlet private weak var datesLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var cardNameLabel: UILabel!
    @IBOutlet private weak var cardImage: UIImageView!
    
    override func getBundleName() -> String {
        return "Cards"
    }
    
    override func commonInit() {
        super.commonInit()
        setAppearance()
        setAccessibilityIdentifiers()
    }
    
    func setInfo(_ viewModel: NextSettlementViewModel) {
        datesLabel.configureText(withLocalizedString: viewModel.datesText)
        amountLabel.attributedText = viewModel.totalAmount
        cardNameLabel.text = viewModel.cardName
        cardImage.loadImage(urlString: viewModel.imageUrl, placeholder: Assets.image(named: "defaultCard"))
    }
}

private extension SingleCardHeaderView {
    func setAppearance() {
        self.backgroundColor = .clear
        datesLabel.setSantanderTextFont(type: .bold, size: 12.0, color: .mediumSanGray)
        amountLabel.setSantanderTextFont(type: .bold, size: 36.0, color: .lisboaGray)
        amountLabel.adjustsFontSizeToFitWidth = true
        cardNameLabel.setSantanderTextFont(type: .regular, size: 13.0, color: .grafite)
        cardImage?.image = UIImage(named: "defaultCard")
        self.cardImage.drawShadow(offset: (x: 0, y: 2), opacity: 0.5, color: .lightGray, radius: 6.0)
    }
    
    func setAccessibilityIdentifiers() {
        datesLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.datesLabel.rawValue
        amountLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.amountLabel.rawValue
        cardNameLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.cardNameLabel.rawValue
        cardImage.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.cardImage.rawValue
    }
}
