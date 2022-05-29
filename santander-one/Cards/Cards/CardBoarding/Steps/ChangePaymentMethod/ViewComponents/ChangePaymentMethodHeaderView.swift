//
//  ChangePaymentMethodHeaderView.swift
//  Cards
//
//  Created by Carlos Monfort Gómez on 07/10/2020.
//

import UIKit
import UI
import CoreFoundationLib

class ChangePaymentMethodHeaderView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setViewModel(_ viewModel: PaymentMethodHeaderViewModel) {
        self.descriptionLabel.configureText(withKey: viewModel.descriptionKey,
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 20),
                                                                                                 lineHeightMultiple: 0.85))
    }
}

private extension ChangePaymentMethodHeaderView {
    func setAppearance() {
        self.view?.backgroundColor = .clear
        self.setTitleLabel()
        self.setDescriptionLabel()
        self.setAccessibilityIdentifiers()
    }
    
    func setTitleLabel() {
        self.titleLabel.textColor = .black
        self.titleLabel.configureText(withKey: "cardBoarding_title_changePayment",
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .regular, size: 38),
                                                                                           lineHeightMultiple: 0.85))
    }
    
    func setDescriptionLabel() {
        self.descriptionLabel.textColor = .lisboaGray
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityCardBoarding.ChangePayment.headerTitle.rawValue
        self.descriptionLabel.accessibilityIdentifier = AccessibilityCardBoarding.ChangePayment.headerDescription.rawValue
    }
}
