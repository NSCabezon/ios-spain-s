//
//  FractionedPaymentView.swift
//  GlobalPosition
//
//  Created by Ignacio González Miró on 23/07/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol FractionedPaymentViewDelegate: AnyObject {
    func didSelect()
}

final class FractionedPaymentView: DesignableView {
    @IBOutlet private weak var container: UIView!
    @IBOutlet private weak var sectionImg: UIImageView!
    @IBOutlet private weak var sectionTitleLabel: UILabel!
    @IBOutlet private weak var sectionDescriptionLabel: UILabel!
    
    weak var delegate: FractionedPaymentViewDelegate?
    
    override func commonInit() {
        super.commonInit()
        self.setupView()
    }
    
    func configSection(image sectionImgName: UIImage?, title sectionTitle: LocalizedStylableText, description sectionDescription: LocalizedStylableText) {
        self.sectionImg.image = sectionImgName
        self.sectionTitleLabel.configureText(withLocalizedString: sectionTitle)
        self.sectionDescriptionLabel.setSantanderTextFont(type: .regular, size: 18.0, color: .lisboaGray)
        self.sectionDescriptionLabel.configureText(withLocalizedString: sectionDescription, andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.8))
        self.sectionDescriptionLabel.adjustsFontSizeToFitWidth = true
    }
}

private extension FractionedPaymentView {
    func setupView() {
        self.setAppearence()
        self.setIdentifiers()
    }
    
    func setAppearence() {
        self.backgroundColor = .clear
        self.sectionTitleLabel.font = UIFont.santander(family: .text, type: .bold, size: 11.0)
        self.sectionTitleLabel.textColor = .mediumSanGray
        let shadowConfiguration = ShadowConfiguration(color: UIColor.darkTorquoise.withAlphaComponent(0.33), opacity: 0.7, radius: 3.0, withOffset: 1, heightOffset: 2)
        self.container.drawRoundedBorderAndShadow(with: shadowConfiguration, cornerRadius: 6.0, borderColor: .lightSkyBlue, borderWith: 1.0)
    }
    
    func setIdentifiers() {
        let accountLocalized: LocalizedStylableText = localized("whatsNew_label_accounts")
        let isAccount = sectionTitleLabel.text == accountLocalized.text
        self.sectionImg.accessibilityIdentifier = isAccount
            ? AccessibilityFractionedPayments.accountImage.rawValue
            : AccessibilityFractionedPayments.cardImage.rawValue
        self.sectionTitleLabel.accessibilityIdentifier = isAccount
            ? AccessibilityFractionedPayments.accountTitle.rawValue
            : AccessibilityFractionedPayments.cardTitle.rawValue
        self.sectionDescriptionLabel.accessibilityIdentifier = AccessibilityFractionedPayments.totalPayments.rawValue
    }
}
