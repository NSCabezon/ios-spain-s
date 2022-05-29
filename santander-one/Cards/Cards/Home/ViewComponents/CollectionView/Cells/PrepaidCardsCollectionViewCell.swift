//
// CreditCardsCollectionViewCell  CardsCollectionViewCell.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/24/19.
//

import UIKit
import UI
import CoreFoundationLib

class PrepaidCardsCollectionViewCell: BaseCardCollectionViewCell {
    
    @IBOutlet weak var creditViewContainer: UIView!
    @IBOutlet weak var opacityView: UIView!
    @IBOutlet weak var activateView: UIView!
    @IBOutlet weak var activateSubtitleLabel: UILabel!
    @IBOutlet weak var activateTitleLabel: UILabel!
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var panLabel: UILabel!
    @IBOutlet weak var availabelAmountLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var cvvLabel: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.activateView.isHidden = true
        self.hideDetailsCard(viewModel?.hideDetailsHomeCardConditions)
        self.containerView.layer.cornerRadius = 12
        self.creditViewContainer.layer.cornerRadius = 4
        self.loadingImageView.tintColor = UIColor.white
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
        if viewModel.maskedPAN {
            self.panLabel.text = viewModel.maskedPANLabel
            self.shareImageView.accessibilityLabel = localized(AccessibilityCardsHome.buttonPAN)
        } else {
            self.panLabel.text = viewModel.pan
            self.shareImageView.accessibilityLabel = localized(AccessibilityCardsHome.buttonShare)
        }
        self.checkIsInactive(viewModel)
        self.aliasLabel.text = viewModel.alias
        self.cvvLabel.text = localized("cardHome_label_cvv")
        self.availableLabel.text = localized("cardHome_label_availableCash")
        self.availabelAmountLabel.attributedText = viewModel.availableAmountAttributedString
        self.hideDetailsCard(viewModel.hideDetailsHomeCardConditions)
        self.setExpirationDate()
    }
    
    override func applyStyle(forState state: CardState) {
        super.applyStyle(forState: state)
        guard let viewModel = self.viewModel else { return }
        self.setLabelsColor(viewModel.tintColor)
        switch state {
        case .active:
            self.containerView.backgroundColor = .clear
            self.loadingImageView.tintColor = UIColor.white
        case .inactive:
            self.loadingImageView.tintColor = viewModel.tintColor
        }
    }
}

extension PrepaidCardsCollectionViewCell: Spendable {
    func setExpenses(_ viewModel: CardViewModel) {
        self.viewModel = viewModel
        self.setExpenses()
    }
}

private extension PrepaidCardsCollectionViewCell {
    func hideDetailsCard(_ hideDetails: Bool?) {
        guard let hide = hideDetails, hide else {
            self.setExpenses()
            return
        }
        self.expensesLabel.isHidden = hide
    }
    
    func setExpirationDate() {
        if let expirationDate = self.viewModel?.expirationDateFormatted {
            self.expirationLabel.text = localized("cardHome_label_availableBalance")
            self.expirationDateLabel.text = expirationDate
        } else {
            self.expirationLabel.text = nil
            self.expirationDateLabel.text = nil
        }
    }
    
    func mustShowDisabledCard() -> Bool {
        guard let viewModel = self.viewModel else { return false }
        return viewModel.isDisabled || viewModel.isInactive
    }
    
    func setLabelsColor(_ color: UIColor) {
        self.aliasLabel.textColor = color
        self.panLabel.textColor = color
        self.availabelAmountLabel.textColor = color
        self.availableLabel.textColor = color
        self.cvvLabel.textColor = color
        self.expirationLabel.textColor = color
        self.expirationDateLabel.textColor = color
        self.expensesLabel.textColor = color
    }
    
    func setExpenses() {
        if let localizedText = self.viewModel?.monthExpensesLocalizedText {
            self.expensesLabel.configureText(withLocalizedString: localizedText)
            self.hideLoading()
        } else {
            self.expensesLabel.text = nil
            self.showLoading()
        }
    }
    
    func showLoading() {
        self.loadingImageView.isHidden = false
        self.loadingImageView.setPointsLoader()
    }
    
    func hideLoading() {
        self.loadingImageView.removeLoader()
        self.loadingImageView.isHidden = true
    }
    
    func checkIsInactive(_ viewModel: CardViewModel) {
        if viewModel.isInactive, viewModel.showActivateView {
            self.isInactive()
        } else {
            self.activateView.isHidden = true
        }
    }

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
    
    func setAccesibilityIdentifiers() {
        self.creditViewContainer.accessibilityIdentifier = AccessibilityPrepaidCardHeader.prepaidViewContainer
        self.aliasLabel.accessibilityIdentifier = AccessibilityPrepaidCardHeader.aliasLabel
        self.panLabel.accessibilityIdentifier = AccessibilityPrepaidCardHeader.panLabel
        self.availabelAmountLabel.accessibilityIdentifier = AccessibilityPrepaidCardHeader.availableAmountLabel
        self.availableLabel.accessibilityIdentifier = AccessibilityPrepaidCardHeader.availableLabel
        self.expirationLabel.accessibilityIdentifier = AccessibilityBaseCardHeader.expirationLabel
        self.expirationDateLabel.accessibilityIdentifier = AccessibilityPrepaidCardHeader.expirationDateLabel
        self.cvvLabel.accessibilityIdentifier = AccessibilityBaseCardHeader.cvvLabel
        self.expensesLabel.accessibilityIdentifier = AccessibilityPrepaidCardHeader.expensesLabel
        self.loadingImageView.accessibilityIdentifier = AccessibilityPrepaidCardHeader.loadingImageView
        self.containerView.accessibilityIdentifier = AccessibilityPrepaidCardHeader.containerView
        self.accessibilityIdentifier = AccessibilityPrepaidCardHeader.prepaidCardView
    }
    
    func setAccessibilityLabels() {
        self.cvvFakeView?.accessibilityLabel = localized(AccessibilityCardsHome.buttonCVV)
        self.activateButton?.accessibilityLabel = localized(AccessibilityBaseCardHeader.activateButton)
    }
}
