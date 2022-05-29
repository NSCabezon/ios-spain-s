//
//  CustomOptionWithTooltipOnboardingView.swift
//  RetailLegacy
//
//  Created by Victor Carrilero García on 15/02/2021.
//

import UIKit
import UI
import CoreFoundationLib

final class CustomOptionWithTooltipOnboardingView: StackItemView {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var iconContentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var shadowContentView: UIView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.separatorView.backgroundColor = .mediumSky
        self.iconContentView.clipsToBounds = true
        self.iconContentView.backgroundColor = .paleSanGrey
        self.titleLabel.applyStyle(LabelStylist(textColor: .uiBlack, font: .santanderTextBold(size: 20), textAlignment: .left))
        self.titleLabel.numberOfLines = 0
        self.titleLabel.set(lineHeightMultiple: 0.8)
        self.descriptionLabel.applyStyle(LabelStylist(textColor: .lisboaGrayNew, font: .santanderTextLight(size: 16), textAlignment: .left))
        self.descriptionLabel.set(lineHeightMultiple: 0.85)
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.sizeToFit()
        self.setAccesibilityIdentifers()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.shadowContentView.drawShadow(offset: CGSize(width: 0.0, height: 2.0), opaticity: 0.7, color: UIColor.lightSanGray, radius: 3.0)
        self.shadowContentView.layer.masksToBounds = false
        self.contentView.drawBorder(cornerRadius: 6.0, color: UIColor.mediumSky)
        self.contentView.layer.masksToBounds = true
    }
    
    func set(title: LocalizedStylableText,
             description: LocalizedStylableText,
             image: String) {
        self.titleLabel.set(localizedStylableText: title)
        self.descriptionLabel.set(localizedStylableText: description)
        self.iconImageView.image = Assets.image(named: image)
    }
}

private extension CustomOptionWithTooltipOnboardingView {
    func setAccesibilityIdentifers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.titleCard
        self.descriptionLabel.accessibilityIdentifier = AccessibilityOnboardingOptions.descriptionCard
    }
}
