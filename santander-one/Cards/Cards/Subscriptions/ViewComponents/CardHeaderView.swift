//
//  CardHeaderView.swift
//  Cards
//
//  Created by Ignacio González Miró on 11/5/21.
//

import UIKit
import UI
import CoreFoundationLib

public final class CardHeaderView: XibView {
    @IBOutlet private weak var cardImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var numEnabledShopsLabel: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: CardSubscriptionViewModel, numOfActiveShops: Int) {
        let cardName = viewModel.cardName ?? ""
        let cardCode = viewModel.cardCode ?? ""
        let urlString = viewModel.cardImageUrl ?? ""
        setTitleLabel(cardName)
        setDescriptionLabel(cardCode)
        cardImageView.loadImage(urlString: urlString,
                                placeholder: Assets.image(named: "defaultCard"))
        setNumEnabledShopsLabel(numOfActiveShops)
    }
}

private extension CardHeaderView {
    func setupView() {
        backgroundColor = .clear
        setAccessibilityIds()
    }
    
    func setTitleLabel(_ cardName: String) {
        descriptionLabel.numberOfLines = 1
        descriptionLabel.textColor = .lisboaGray
        let textConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 16), alignment: .left, lineHeightMultiple: 0.9, lineBreakMode: .byTruncatingTail)
        titleLabel.configureText(withKey: cardName,
                                 andConfiguration: textConfig)
    }
    
    func setDescriptionLabel(_ cardCode: String) {
        descriptionLabel.numberOfLines = 1
        descriptionLabel.textColor = .lisboaGray
        let descriptionConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 14), alignment: .left, lineBreakMode: .byTruncatingTail)
        descriptionLabel.configureText(withKey: cardCode,
                                       andConfiguration: descriptionConfig)
    }
    
    func setNumEnabledShopsLabel(_ numOfActiveShops: Int) {
        numEnabledShopsLabel.numberOfLines = 2
        numEnabledShopsLabel.textColor = .brownishGray
        let numConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 14), alignment: .right, lineHeightMultiple: 0.8, lineBreakMode: .byTruncatingTail)
        let key = numOfActiveShops == 1 ? "m4m_label_activeCommerce_one" : "m4m_label_activeCommerce_other"
        let stringPlaceHolder = [StringPlaceholder(.number, "\(numOfActiveShops)")]
        numEnabledShopsLabel.configureText(withLocalizedString: localized(key, stringPlaceHolder),
                                           andConfiguration: numConfig)
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityCardSubscription.cardHeaderBaseView
        cardImageView.accessibilityIdentifier = AccessibilityCardSubscription.cardHeaderCardImageView
        titleLabel.accessibilityIdentifier = AccessibilityCardSubscription.cardHeaderTitleLabel
        descriptionLabel.accessibilityIdentifier = AccessibilityCardSubscription.cardHeaderDescriptionLabel
        numEnabledShopsLabel.accessibilityIdentifier = AccessibilityCardSubscription.cardHeaderNumEnabledShopsLabel
    }
}
