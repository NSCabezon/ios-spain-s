//
//  NewShipmentCollectionViewCell.swift
//  Transfer
//
//  Created by José Carlos Estela Anguita on 05/02/2020.
//

import Foundation
import CoreFoundationLib
import UI

final class NewShipmentCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet private weak var circleView: UIView!
    @IBOutlet private weak var transferLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var bizumImage: UIImageView!
    @IBOutlet private weak var newSendLabel: UILabel!
    @IBOutlet private weak var andLabel: UILabel!
    
    // MARK: - Public
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.circleView.layer.cornerRadius = self.circleView.frame.size.width / 2
    }
}

private extension NewShipmentCollectionViewCell {
    func setupView() {
        self.configureTransferView()
        self.configureShadow()
        self.setupAccessibility()
        self.setupAccessibilityId()
        self.setAccessibilityLabel()
        self.disableAccessibilityElements()
    }
    
    func configureShadow() {
        self.containerView.backgroundColor = UIColor.white
        self.containerView.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.containerView.layer.shadowOpacity = 0.59
        self.containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        self.containerView.layer.shadowRadius = 0.0
        self.containerView.layer.masksToBounds = false
        self.containerView.clipsToBounds = false
        self.containerView.drawBorder(cornerRadius: 5, color: UIColor.lightSkyBlue, width: 1)
    }
    
    func configureTransferView() {
        self.bizumImage.image = Assets.image(named: "icnSendMoneyMobile")
        self.configureBackgroundView()
        self.configureTransferLabels()
    }
    
    func configureBackgroundView() {
        self.circleView.backgroundColor = UIColor.botonRedLight
        self.circleView.clipsToBounds = true
    }
    
    func configureTransferLabels() {
        self.newSendLabel.text = localized("transfer_button_newSend")
        self.newSendLabel.font = UIFont.santander(family: .text, type: .bold, size: 16.0)
        self.newSendLabel.textColor = UIColor.lisboaGray
        self.setParagraphStyle(to: self.transferLabel, text: localized("transfer_text_button_newSend"))
        self.andLabel.text = localized("generic_text_and")
        self.andLabel.font = UIFont.santander(family: .text, type: .regular, size: 11.0)
        self.andLabel.textColor = UIColor.mediumSanGray
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
    
    func setupAccessibility() {
        self.setupAccessibilityId()
        self.setAccessibilityValue()
        self.disableAccessibilityElements()
    }
    
    func setupAccessibilityId() {
        self.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeBtnNewTransferSend
        self.circleView.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeViewNewButtonCircle
        self.transferLabel.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeLabelNewTransferTitle
        self.bizumImage.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeViewNewTransferImage
        self.newSendLabel.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeLabelNewTransferDesc
        self.andLabel.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyLabelNewTransferAnd
    }
    
    func setAccessibilityValue() {
        self.newSendLabel.accessibilityTraits = .button
        self.newSendLabel.accessibilityLabel = "\(localized("transfer_button_newSend")). \(localized("transfer_text_button_newSend"))"
        self.transferLabel.accessibilityElementsHidden = true
        self.andLabel.accessibilityElementsHidden = true
        self.setAccessibilityLabel()
    }
    
    func setAccessibilityLabel() {
        let newSendValue = self.newSendLabel.attributedText?.string ?? ""
        let transferValue = self.transferLabel.text ?? ""
        let andValue = self.andLabel.text ?? ""
        self.accessibilityLabel = newSendValue +
            transferValue +
            andValue +
            localized("voiceover_optionSendMoneyMobile")
        self.accessibilityTraits = .button
        self.isAccessibilityElement = true
    }
    
    func disableAccessibilityElements() {
        self.newSendLabel.isAccessibilityElement = false
        self.transferLabel.isAccessibilityElement = false
        self.andLabel.isAccessibilityElement = false
    }
}
