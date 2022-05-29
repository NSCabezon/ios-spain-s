//
//  CreditCardsCollectionViewCell.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/24/19.
//

import UIKit
import UI
import CoreFoundationLib

class CreditCardsCollectionViewCell: BaseCardCollectionViewCell {
    @IBOutlet weak var opacityView: UIView!
    @IBOutlet weak var activateView: UIView!
    @IBOutlet weak var activateSubtitleLabel: UILabel!
    @IBOutlet weak var activateTitleLabel: UILabel!
    @IBOutlet weak var creditViewContainer: UIView!
    @IBOutlet weak var progressBarView: ProgressBar!
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var panLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var cvvLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var availableAmountLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var limitAmountLabel: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.activateView.isHidden = true
        self.viewContainer.layer.cornerRadius = 12
        self.viewContainer.backgroundColor = .clear
        self.creditViewContainer.layer.cornerRadius = 12
        self.setAccesibilityIdentifiers()
        self.setAccessibilityLabels()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.activateView.isHidden = true
        cardImg?.image = nil
        currentTask?.cancel()
    }
    
    func configure(_ viewModel: CardViewModel) {
        self.viewModel = viewModel
        if viewModel.isDisabled || viewModel.isInactive {
            self.applyStyle(forState: .inactive)
        } else {
            self.applyStyle(forState: .active)
        }
        if viewModel.isInactive {
            self.isInactive()
        } else {
            self.activateView.isHidden = true
        }
        self.aliasLabel.text = viewModel.alias
        self.aliasLabel.font = UIFont.santander(family: .text, type: .bold, size: 18)
        if viewModel.maskedPAN {
            self.panLabel.text = viewModel.maskedPANLabel
            self.shareImageView.accessibilityLabel = localized(AccessibilityCardsHome.buttonPAN)
        } else {
            self.panLabel.text = viewModel.pan
            self.shareImageView.accessibilityLabel = localized(AccessibilityCardsHome.buttonShare)
        }
        self.progressBarView.setProgressPercentage(0)
        self.panLabel.setSantanderTextFont(type: .regular, size: 14, color: viewModel.tintColor)
        self.cvvLabel.text = localized("cardHome_label_cvv")
        self.cvvLabel.font = UIFont.santander(family: .text, type: .regular, size: 13)
        self.balanceLabel.attributedText = viewModel.balanceAmountAttributedString
        self.balanceLabel.font = UIFont.santander(family: .text, type: .bold, size: 32)
        self.creditLabel.text = localized("cardsHome_label_proposed")
        self.creditLabel.font = UIFont.santander(family: .text, type: .regular, size: 13)
        self.setExpirationDate()
        self.availableAmountLabel.configureText(withLocalizedString: viewModel.availableAmountLocalizedText)
        self.availableAmountLabel.font = UIFont.santander(family: .text, type: .regular, size: 13)
        self.limitAmountLabel.configureText(withLocalizedString: viewModel.creditLimitsAmountLocalizedText)
        self.limitAmountLabel.font = UIFont.santander(family: .text, type: .regular, size: 13)
        self.creditViewContainer.backgroundColor = .clear
    }
    
    override func applyStyle(forState state: CardState) {
        super.applyStyle(forState: state)
        guard let viewModel = self.viewModel else {
            return
        }
        self.setLabelsColor(viewModel.tintColor)
        switch state {
        case .active:
            self.viewContainer.backgroundColor = .clear
            self.progressBarView.setProgresColor(UIColor.darkTorquoise)
        case .inactive:
            self.progressBarView.setProgresColor(UIColor.coolGray)
        }
    }
    
    func animateProgress() {
        guard let viewModel = viewModel else {
            self.progressBarView.setProgressPercentage(0)
            return
        }
        let value = CGFloat(viewModel.creditExpenses)
        self.progressBarView.setProgressPercentageAnimated(value)
    }
}

private extension CreditCardsCollectionViewCell {
    func isInactive() {
        self.activateView.isHidden = false
        self.activateTitleLabel.textColor = .black
        self.activateTitleLabel?.configureText(withKey: "cardHome_label_inactiveCard",
                                               andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16)))
        self.activateSubtitleLabel.textColor = .black
        self.activateSubtitleLabel?.configureText(withKey: "cardHome_text_activateCard",
                                                  andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 12)))
        self.opacityView.layer.opacity = 0.7
        self.opacityView.drawBorder(cornerRadius: 8, color: .white, width: 1)
    }
    
    func setExpirationDate() {
        if let expirationDate = self.viewModel?.expirationDateFormatted {
            self.expirationLabel.text = localized("cardHome_label_availableBalance")
            self.expirationLabel.font = UIFont.santander(family: .text, type: .regular, size: 13)
            self.expirationDateLabel.text = expirationDate
            self.expirationDateLabel.font = UIFont.santander(family: .text, type: .bold, size: 13)
        } else {
            self.expirationLabel.text = nil
            self.expirationDateLabel.text = nil
        }
    }
    
    func setLabelsColor(_ color: UIColor) {
        self.aliasLabel.textColor = color
        self.panLabel.textColor = color
        self.balanceLabel.textColor = color
        self.creditLabel.textColor = color
        self.availableAmountLabel.textColor = color
        self.limitAmountLabel.textColor = color
        self.cvvLabel.textColor = color
        self.expirationLabel.textColor = color
        self.expirationDateLabel.textColor = color
    }
    
    func setAccesibilityIdentifiers() {
        self.creditViewContainer.accessibilityIdentifier =  AccessibilityCreditCardHeader.creditViewContainer
        self.progressBarView.accessibilityIdentifier = AccessibilityCreditCardHeader.progressBarView
        self.aliasLabel.accessibilityIdentifier = AccessibilityCreditCardHeader.aliasLabel
        self.panLabel.accessibilityIdentifier = AccessibilityCreditCardHeader.panLabel
        self.expirationLabel.accessibilityIdentifier = AccessibilityBaseCardHeader.expirationLabel
        self.expirationDateLabel.accessibilityIdentifier = AccessibilityCreditCardHeader.expirationDateLabel
        self.cvvLabel.accessibilityIdentifier = AccessibilityBaseCardHeader.cvvLabel
        self.balanceLabel.accessibilityIdentifier = AccessibilityCreditCardHeader.balanceLabel
        self.availableAmountLabel.accessibilityIdentifier = AccessibilityCreditCardHeader.availableAmountLabel
        self.creditLabel.accessibilityIdentifier = AccessibilityCreditCardHeader.creditLabel
        self.limitAmountLabel.accessibilityIdentifier = AccessibilityCreditCardHeader.limitAmountLabel
        self.viewContainer.accessibilityIdentifier = AccessibilityCreditCardHeader.viewContainer
        self.accessibilityIdentifier = AccessibilityCreditCardHeader.creditCardView
        self.cvvFakeView?.accessibilityLabel = localized(AccessibilityCardsHome.buttonCVV)
    }
    
    func setAccessibilityLabels() {
        self.cvvFakeView?.accessibilityLabel = localized(AccessibilityCardsHome.buttonCVV)
        self.activateButton?.accessibilityLabel = localized(AccessibilityBaseCardHeader.activateButton)
    }
}
