//
//  CardBoardingGeolocationHeaderView.swift
//  Cards
//
//  Created by Carlos Monfort Gómez on 11/11/2020.
//

import Foundation
import UI
import CoreFoundationLib

class CardBoardingGeolocationHeaderView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
}

private extension CardBoardingGeolocationHeaderView {
    func setAppearance() {
        self.view?.backgroundColor = .clear
        self.setTitleLabel()
        self.setDescriptionLabel()
        self.setAccessibilityIdentifiers()
    }
    
    func setTitleLabel() {
        self.titleLabel.textColor = .black
        self.titleLabel.configureText(withKey: "cardBoarding_title_geolocation",
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .regular, size: 38),
                                                                                           lineHeightMultiple: 0.85))
    }
    
    func setDescriptionLabel() {
        self.descriptionLabel.textColor = .lisboaGray
        self.descriptionLabel.configureText(withKey: "cardBoarding_text_descriptionGeolocation",
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 20),
                                                                                                 lineHeightMultiple: 0.85))
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityCardBoarding.Geolocation.headerTitle
        self.descriptionLabel.accessibilityIdentifier = AccessibilityCardBoarding.Geolocation.headerDescription
    }
}
