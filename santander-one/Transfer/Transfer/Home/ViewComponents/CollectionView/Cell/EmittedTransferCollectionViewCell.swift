//
//  EmittedTransferCollectionViewCell.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/18/19.
//

import UIKit
import CoreFoundationLib
import UI

final class EmittedTransferCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var beneficiaryLabel: UILabel!
    @IBOutlet private weak var ibanLabel: UILabel!
    @IBOutlet private weak var backImageView: UIImageView!
    @IBOutlet private weak var executedDateLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var arrowImage: UIImageView!
    private var groupedAccessibilityElements: [Any]?

    override func awakeFromNib() {
        super.awakeFromNib()
        [beneficiaryLabel,
         ibanLabel,
         executedDateLabel,
         amountLabel].forEach { $0?.text = "" }
        self.setAppearance()
    }
    
    private func setAppearance() {
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.layer.shadowOpacity = 0.59
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        self.layer.shadowRadius = 0.0
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.drawBorder(cornerRadius: 4, color: UIColor.lightSkyBlue, width: 1)
        self.ibanLabel.font = UIFont.santander(family: .text, type: .regular, size: 13.0)
        self.ibanLabel.textColor = .mediumSanGray
        self.executedDateLabel.font = UIFont.santander(family: .text, type: .bold, size: 10.0)
        self.executedDateLabel.textColor = .bostonRed
        self.amountLabel.textColor = .lisboaGray
        self.amountLabel.font = UIFont.santander(family: .text, type: .bold, size: 16.0)
        self.beneficiaryLabel.textColor = .lisboaGray
        self.beneficiaryLabel.font = UIFont.santander(family: .text, type: .bold, size: 14.0)
    }
    
    func configure(_ viewModel: TransferViewModel) {
        self.setParagraphStyle(to: self.beneficiaryLabel, text: viewModel.beneficiary ?? "")
        self.ibanLabel.text = viewModel.iban
        self.executedDateLabel.text = viewModel.executedDateString
        self.amountLabel.attributedText = viewModel.amountSmallFont
        if let iconUrl = viewModel.bankIconUrl {
            backImageView.loadImage(urlString: iconUrl)
        }
        let imageName = viewModel.transferType == .emitted ? "icnArrowSmallSendRed" : "icnArrowSmallSendGreen"
        self.arrowImage.image = Assets.image(named: imageName)
        self.setAccessibility()
    }
    
    private func setParagraphStyle(to label: UILabel, text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        paragraphStyle.alignment = .left
        label.baselineAdjustment = .alignCenters
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.lineHeightMultiple = 0.75
        let builder = TextStylizer.Builder(fullText: text)
        label.attributedText = builder
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: text)
                .setStyle(UIFont.santander(family: .text, type: .bold, size: 14))
                .setColor(.lisboaGray)
                .setParagraphStyle(paragraphStyle)
            )
            .build()
    }
    
    private func setAccessibility() {
        self.beneficiaryLabel.accessibilityTraits = .button
        self.ibanLabel.accessibilityElementsHidden = true
        self.executedDateLabel.accessibilityElementsHidden = true
        self.amountLabel.accessibilityElementsHidden = true
        self.setAccessibilityIds()
    }
    
    private func setAccessibilityIds() {
        self.containerView.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeViewEmittedCellContainer
        self.beneficiaryLabel.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeLabelEmittedCellBeneficiary
        self.ibanLabel.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeLabelEmittedCellIban
        self.backImageView.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeViewEmittedCellBackImage
        self.executedDateLabel.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeLabelEmittedCellExecutedDate
        self.amountLabel.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeLabelEmittedCellAmount
        self.arrowImage.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeViewEmittedCellArrow
    }
}

extension EmittedTransferCollectionViewCell {
    public override var accessibilityElements: [Any]? {
        get {
            if let groupedAccessibilityElements = groupedAccessibilityElements {
                return groupedAccessibilityElements
            }
            let elements = self.groupElements([beneficiaryLabel,
                                               ibanLabel,
                                               executedDateLabel,
                                               amountLabel])
            groupedAccessibilityElements = elements
            return groupedAccessibilityElements
        }
        set {
            groupedAccessibilityElements = newValue
        }
    }
}
