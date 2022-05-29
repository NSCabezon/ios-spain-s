//
//  PurchaseStatusView.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 1/3/21.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

public final class PurchaseStatusView: XibView {
    @IBOutlet private weak var statusStackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ status: EcommercePaymentStatus) {
        self.configImageView(status)
        self.configTitle(status)
        self.configDescription(status)
        self.configDescriptionColor(status)
    }
}

private extension PurchaseStatusView {
    // MARK: - Common init
    func setupView() {
        self.backgroundColor = .clear
        self.titleLabel.numberOfLines = 0
        self.titleLabel.textColor = .lisboaGray
        self.descriptionLabel.numberOfLines = 0
    }
    
    func setAccessibilityIds() {
        self.accessibilityIdentifier = AccessibilityEcommercePurchaseStatusView.baseView
        self.titleLabel.accessibilityIdentifier = AccessibilityEcommercePurchaseStatusView.titleLabel
        self.descriptionLabel.accessibilityIdentifier = AccessibilityEcommercePurchaseStatusView.descriptionLabel
    }
    
    // MARK: - View Configurations
    func configTitle(_ status: EcommercePaymentStatus) {
        var localizedKey = String()
        switch status {
        case .identifying:
            localizedKey = ""
        case .success:
            localizedKey = "ecommerce_label_okIdentification"
        case .errorConfirmation, .errorData:
            localizedKey = "ecommerce_label_Attention"
        case .expired:
            localizedKey = ""
        }
        let font: UIFont
        if case .success = status {
            font = .santander(family: .headline, type: .bold, size: 20)
        } else {
            font = .santander(family: .headline, type: .bold, size: 24)
        }
        let localizedConfiguration = LocalizedStylableTextConfiguration(font: font,
                                                                        alignment: .center,
                                                                        lineHeightMultiple: 0.8,
                                                                        lineBreakMode: .byTruncatingTail)
        self.titleLabel.configureText(withKey: localizedKey, andConfiguration: localizedConfiguration)
        self.titleLabel.isHidden = localizedKey.isEmpty
    }
    
    func configDescription(_ status: EcommercePaymentStatus) {
        let font: UIFont
        if case .success = status {
            font = .santander(family: .headline, type: .regular, size: 13)
        } else {
            font = .santander(family: .headline, type: .regular, size: 16)
        }
        let localizedConfiguration = LocalizedStylableTextConfiguration(font: font,
                                                                        alignment: .center,
                                                                        lineBreakMode: .byTruncatingTail)
        self.descriptionLabel.configureText(withKey: status.messageKey(),
                                            andConfiguration: localizedConfiguration)
    }
    
    func configImageView(_ status: EcommercePaymentStatus) {
        self.removeArrangedSubviewsIfNeeded()
        switch status {
        case .identifying, .success, .expired:
            self.addDefaultView(status)
        case .errorConfirmation, .errorData:
            self.addErrorConfirmationView()
        }
    }
    
    func addDefaultView(_ status: EcommercePaymentStatus) {
        let view = EcommercePurchaseStatusDefaultView()
        view.configView(status)
        self.statusStackView.addArrangedSubview(view)
    }
    
    func addErrorConfirmationView() {
        let view = EcommercePurchaseStatusErrorView()
        self.statusStackView.addArrangedSubview(view)
    }
    
    func removeArrangedSubviewsIfNeeded() {
        if !self.statusStackView.arrangedSubviews.isEmpty {
            self.statusStackView.removeAllArrangedSubviews()
        }
    }
    
    func configDescriptionColor(_ status: EcommercePaymentStatus) {
        var textColor: UIColor?
        switch status {
        case .identifying, .success, .errorConfirmation, .errorData:
            textColor = .lisboaGray
        case .expired:
            textColor = .bostonRedLight
        }
        self.descriptionLabel.textColor = textColor
    }
}
