//
//  EcommerceField.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 17/2/21.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

public final class EcommerceField: XibView {
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var cardImageView: UIImageView!
    @IBOutlet private weak var cardCodeLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ info: EcommerceViewModel) {
        self.amountLabel.attributedText = info.totalAmount
        self.descriptionLabel.text = info.tradeName
        self.cardCodeLabel.configureText(withLocalizedString: info.panShort)
    }
}

private extension EcommerceField {
    func setupView() {
        self.backgroundColor = .clear
        self.cardImageView.image = Assets.image(named: "icnCardEcommerce")
        self.setAmountLabel()
        self.setDescriptionLabel()
        self.setCardCodeLabel()
        self.setAccessibilityIds()
    }
    
    func setAmountLabel() {
        self.amountLabel.textColor = .lisboaGray
        self.amountLabel.textAlignment = .left
        self.amountLabel.adjustsFontSizeToFitWidth = true
    }
    
    func setDescriptionLabel() {
        self.descriptionLabel.font = UIFont.santander(family: .text, type: .regular, size: 13)
        self.descriptionLabel.textAlignment = .left
        self.descriptionLabel.textColor = .brownGray
        self.descriptionLabel.numberOfLines = 2
        self.descriptionLabel.lineBreakMode = .byTruncatingTail
    }
    
    func setCardCodeLabel() {
        self.cardCodeLabel.font = UIFont.santander(family: .text, type: .light, size: 16)
        self.cardCodeLabel.textAlignment = .right
        self.cardCodeLabel.textColor = .lisboaGray
        self.cardCodeLabel.adjustsFontSizeToFitWidth = true
    }
    
    func setAccessibilityIds() {
        self.amountLabel.accessibilityIdentifier = AccessibilityEcommerceTicketField.amountLabel
        self.cardImageView.accessibilityIdentifier = AccessibilityEcommerceTicketField.cardImageView
        self.descriptionLabel.accessibilityIdentifier = AccessibilityEcommerceTicketField.descriptionLabel
        self.cardCodeLabel.accessibilityIdentifier = AccessibilityEcommerceTicketField.cardCodeLabel
        self.accessibilityIdentifier = AccessibilityEcommerceTicketField.baseView
    }
}
