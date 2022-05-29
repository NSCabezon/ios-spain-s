//
// CreditCardsCollectionViewCell  CardsCollectionViewCell.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/24/19.
//

import UIKit
import UI
import CoreFoundationLib

class DebitCardsCollectionViewCell: BaseCardCollectionViewCell {
    
    @IBOutlet weak var opacityView: UIView!
    @IBOutlet weak var activateView: UIView!
    @IBOutlet weak var activateSubtitleLabel: UILabel!
    @IBOutlet weak var activateTitleLabel: UILabel!
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var panLabel: UILabel!
    @IBOutlet weak var monthExpensesAmountLabel: UILabel!
    @IBOutlet weak var monthExpensesLabel: UILabel!
    @IBOutlet weak var shopLimitsLabel: UILabel!
    @IBOutlet weak var atmLimitsLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var cvvLabel: UILabel!
    @IBOutlet weak var containterView: UIView!
    @IBOutlet weak var loadingImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.activateView.isHidden = true
        self.containterView.layer.cornerRadius = 12
        self.loadingImageView.tintColor = UIColor.white
        self.hideDetailsCard(viewModel?.hideDetailsHomeCardConditions)
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
        if viewModel.maskedPAN {
            self.panLabel.text = viewModel.maskedPANLabel
            self.shareImageView.accessibilityLabel = localized(AccessibilityCardsHome.buttonPAN)
        } else {
            self.panLabel.text = viewModel.pan
            self.shareImageView.accessibilityLabel = localized(AccessibilityCardsHome.buttonShare)
        }
        self.panLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        self.aliasLabel.text = viewModel.alias
        self.aliasLabel.font = UIFont.santander(family: .text, type: .bold, size: 18)
        self.cvvLabel.text = localized("cardHome_label_cvv")
        self.cvvLabel.font = UIFont.santander(family: .text, type: .regular, size: 13)
        self.hideDetailsCard(viewModel.hideDetailsHomeCardConditions)
        self.setExpirationDate()
    }
    
    override func applyStyle(forState state: CardState) {
        super.applyStyle(forState: state)
        guard let viewModel = self.viewModel else {
            return
        }
        self.setLabelsColor(viewModel.tintColor)
    }
}

private extension DebitCardsCollectionViewCell {
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
    
    func hideDetailsCard(_ hideDetails: Bool?) {
        guard let model = viewModel else { return }
        guard let hide = hideDetails, hide else {
            self.shopLimitsLabel.configureText(withLocalizedString: model.shopLimitAmountLocalizedText)
            self.atmLimitsLabel.configureText(withLocalizedString: model.atmDailyLimitAmountLocalizedText)
            self.setExpenses()
            return
        }
        self.monthExpensesAmountLabel.isHidden = hide
        self.monthExpensesLabel.isHidden = hide
        self.shopLimitsLabel.isHidden = hide
        self.atmLimitsLabel.isHidden = hide
    }
    
    func setExpirationDate() {
        if let expirationDate = self.viewModel?.expirationDateFormatted {
            self.expirationLabel.text = localized("cardHome_label_availableBalance")
            self.expirationDateLabel.text = expirationDate
            self.expirationLabel.font = UIFont.santander(family: .text, type: .regular, size: 13)
            self.expirationDateLabel.font = UIFont.santander(family: .text, type: .bold, size: 13)
        } else {
            self.expirationLabel.text = nil
            self.expirationDateLabel.text = nil
        }
    }
    
    func setLabelsColor(_ color: UIColor) {
        self.aliasLabel.textColor = color
        self.panLabel.textColor = color
        self.monthExpensesAmountLabel.textColor = color
        self.monthExpensesLabel.textColor = color
        self.shopLimitsLabel.textColor = color
        self.atmLimitsLabel.textColor = color
        self.cvvLabel.textColor = color
        self.expirationLabel.textColor = color
        self.expirationDateLabel.textColor = color
    }
    
    func setExpenses() {
        if let monthExpenses = self.viewModel?.monthExpensesAttriburtedString {
            self.monthExpensesAmountLabel.attributedText = monthExpenses
            self.monthExpensesLabel.text = localized("card_label_spentMonth")
            self.monthExpensesAmountLabel.font = UIFont.santander(family: .text, type: .bold, size: 32)
            self.monthExpensesLabel.font = UIFont.santander(family: .text, type: .regular, size: 13)
            self.hideLoading()
        } else {
            self.monthExpensesAmountLabel.attributedText = nil
            self.monthExpensesLabel.text = nil
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
    
    func setAccesibilityIdentifiers() {
        self.aliasLabel.accessibilityIdentifier = AccessibilityDebitCardHeader.aliasLabel
        self.panLabel.accessibilityIdentifier = AccessibilityDebitCardHeader.panLabel
        self.monthExpensesAmountLabel.accessibilityIdentifier = AccessibilityDebitCardHeader.monthExpensesAmountLabel
        self.monthExpensesLabel.accessibilityIdentifier = AccessibilityDebitCardHeader.monthExpensesLabel
        self.shopLimitsLabel.accessibilityIdentifier = AccessibilityDebitCardHeader.shopLimitsLabel
        self.atmLimitsLabel.accessibilityIdentifier = AccessibilityDebitCardHeader.atmLimitsLabel
        self.expirationLabel.accessibilityIdentifier = AccessibilityBaseCardHeader.expirationLabel
        self.expirationDateLabel.accessibilityIdentifier = AccessibilityDebitCardHeader.expirationDateLabel
        self.cvvLabel.accessibilityIdentifier = AccessibilityBaseCardHeader.cvvLabel
        self.containterView.accessibilityIdentifier = AccessibilityDebitCardHeader.containterView
        self.loadingImageView.accessibilityIdentifier = AccessibilityDebitCardHeader.loadingImageView
        self.accessibilityIdentifier = AccessibilityDebitCardHeader.debitCardView
    }
    
    func setAccessibilityLabels() {
        self.cvvFakeView?.accessibilityLabel = localized(AccessibilityCardsHome.buttonCVV)
        self.activateButton?.accessibilityLabel = localized(AccessibilityBaseCardHeader.activateButton)
    }
}

extension DebitCardsCollectionViewCell: Spendable {
    func setExpenses(_ viewModel: CardViewModel) {
        self.viewModel = viewModel
        self.setExpenses()
    }
}
