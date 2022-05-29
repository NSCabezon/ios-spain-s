//
//  PaymentTypeView.swift
//  Cards
//
//  Created by Laura González on 06/10/2020.
//

import Foundation
import UI
import CoreFoundationLib

final class PaymentTypeView: UIDesignableView {
    
    @IBOutlet private weak var paymentTypeTextLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var descriptionLabelHeight: NSLayoutConstraint!
    
    override func getBundleName() -> String {
        return "Cards"
    }
    
    override func commonInit() {
        super.commonInit()
        setupView()
        setAccessibilityIdentifiers()
    }
    
    func setInfo(_ viewModel: PaymentTypeViewModel) {
        paymentTypeTextLabel.configureText(withLocalizedString: viewModel.paymentMethodLabel)
        if viewModel.hideDisclaimer == true { hideDisclaimer() }
    }
}

private extension PaymentTypeView {
    func setupView() {
        self.backgroundColor = .paleYellow
        self.translatesAutoresizingMaskIntoConstraints = false
        paymentTypeTextLabel.setSantanderTextFont(type: .regular, size: 13.0, color: .lisboaGray)
        descriptionLabel.textColor = .lisboaGray
        descriptionLabel.configureText(withKey: "nextSettlement_text_typePayament",
                                       andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 12)))
        descriptionLabel.adjustsFontSizeToFitWidth = true
    }
    
    func hideDisclaimer() {
        self.descriptionLabel.isHidden = true
        self.descriptionLabelHeight.priority = UILayoutPriority(1000)
        self.descriptionLabelHeight.constant = 0.0
    }
    
    func setAccessibilityIdentifiers() {
        paymentTypeTextLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.paymentTypeTextLabel.rawValue
        descriptionLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.paymentTypedescriptionLabel.rawValue
    }
}
