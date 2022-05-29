//
//  EmptyMovementsView.swift
//  Cards
//
//  Created by Laura González on 08/10/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class EmptyMovementsView: UIDesignableView {
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    
    override func getBundleName() -> String {
        return "Cards"
    }
    
    override func commonInit() {
        super.commonInit()
        setupView()
        self.descriptionLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.emptyMovementsLabel.rawValue
    }
    
    func modifyConstraints() {
        self.topConstraint.constant = 20.0
        self.bottomConstraint.constant = 20.0
    }
}

private extension EmptyMovementsView {
    func setupView() {
        self.backgroundColor = .clear
        self.descriptionLabel.textColor = .lisboaGray
        self.descriptionLabel.configureText(withKey: "generic_label_emptyNotAvailableMoves",
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16.0)))
        self.descriptionLabel.adjustsFontSizeToFitWidth = true
    }
}
