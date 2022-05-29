//
//  HistoricSendMoneyCell.swift
//  GlobalPosition
//
//  Created by Ignacio González Miró on 28/10/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class HistoricSendMoneyCell: UICollectionViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var circleImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    func configureShadow() {
        self.drawShadow(offset: 2, opaticity: 1, color: UIColor.lightSanGray, radius: 1)
        self.layer.masksToBounds = false
    }
}

private extension HistoricSendMoneyCell {
    func setupView() {
        self.setContainerView()
        self.setLabels()
        self.configHistoricSendMoneyPill()
        self.setAccessibilityIds()
        self.setAccessibilityLabel()
        self.disableAccessibilityElements()
    }
    
    func setContainerView() {
        self.containerView.layer.cornerRadius = 5.0
        self.containerView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.containerView.layer.borderWidth = 1.0
        self.containerView.backgroundColor = UIColor.white
    }
    
    func setLabels() {
        self.titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 16)
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = .lisboaGray
    }
    
    func configHistoricSendMoneyPill() {
        self.circleImage.image = Assets.image(named: "icnSendHistorical")
        self.titleLabel.text = localized("pg_label_sendHistorical")
        self.setParagraphStyle(to: descriptionLabel, text: localized("pg_text_button_reviewAllSendMoney"))
    }
    
    func setParagraphStyle(to label: UILabel, text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineHeightMultiple = 0.75
        let builder = TextStylizer.Builder(fullText: text)
        label.attributedText = builder
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: text).setStyle(UIFont.santander(family: .text, type: .regular, size: 11)))
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: text).setParagraphStyle(paragraphStyle))
            .build()
        label.textColor = UIColor.mediumSanGray
    }
    
    func setAccessibilityIds() {
        self.containerView.accessibilityIdentifier = AccessibilityPGFavouriteCarousel.historicSendMoneyPill.rawValue
        self.circleImage.accessibilityIdentifier = AccessibilityPGFavouriteCarousel.historicSmPillImage.rawValue
        self.titleLabel.accessibilityIdentifier = AccessibilityPGFavouriteCarousel.historicSmPillTitle.rawValue
        self.descriptionLabel.accessibilityIdentifier = AccessibilityPGFavouriteCarousel.historicSmPillDescription.rawValue
    }
    
    func setAccessibilityLabel() {
        let titleValue = self.titleLabel.text ?? ""
        let descriptionValue = self.descriptionLabel.attributedText?.string ?? ""
        self.accessibilityValue = titleValue + "\n" +
            descriptionValue
        self.accessibilityTraits = .button
        self.isAccessibilityElement = true
    }
    
    func disableAccessibilityElements() {
        self.titleLabel.isAccessibilityElement = false
        self.descriptionLabel.isAccessibilityElement = false
    }
}
