//
//  CardBoardingActivationSuccessView.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 06/11/2020.
//

import Foundation

import UIKit
import UI
import CoreFoundationLib

class CardBoardingActivationSuccessView: XibView {
   
    @IBOutlet private weak var ticImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setDescriptionText(_ key: String) {
        self.subtitleLabel.configureText(withKey: key)
    }
}

private extension CardBoardingActivationSuccessView {
    func setAppearance() {
        self.ticImageView.image = Assets.image(named: "icnCheckToast")
        self.setLabels()
        self.drawShadow(offset: (x: 0, y: -2), opacity: 0.3, color: .lightSanGray, radius: 0)
        self.setAccesibilityIdentifers()
    }
    
    func setLabels() {
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 18)
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.configureText(withKey: "cardBoarding_text_brilliant")
        self.subtitleLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.subtitleLabel.textColor = .lisboaGray
    }
    
    func setAccesibilityIdentifers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityCardBoarding.ActivatedNotifications.titleLabel
        self.subtitleLabel.accessibilityIdentifier = AccessibilityCardBoarding.ActivatedNotifications.subtitleLabel
        self.ticImageView.accessibilityIdentifier = AccessibilityCardBoarding.ActivatedNotifications.ticIcn
    }
}
