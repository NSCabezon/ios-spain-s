//
//  LastMovementsHeaderView.swift
//  GlobalPosition
//
//  Created by Ignacio González Miró on 15/07/2020.
//

import UIKit
import UI
import CoreFoundationLib

class LastMovementsHeaderView: DesignableView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var numberOfMovementsLabel: UILabel!
    
    override func commonInit() {
        super.commonInit()
        self.setupView()
    }
    
    func configHeader(_ title: LocalizedStylableText, _ numberOfMovements: Int, _ isSmallList: Bool, section: LastMovementsConfiguration.FractionableSection) {
        self.titleLabel.isHidden = !isSmallList
        self.titleLabel.configureText(withLocalizedString: title)
        let numberOfComponents = self.attributedNumberOfMovements(numberOfMovements, isSmallList: isSmallList, section: section)
        self.numberOfMovementsLabel.attributedText = numberOfComponents
        let isLastMovements = section == .lastMovements
        self.setIdentifiers(isLastMovements: isLastMovements)
    }
}

private extension LastMovementsHeaderView {
    func setupView() {
        self.backgroundColor = .clear
        self.setAppearance()
    }
    
    func setAppearance() {
        self.titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 14.0)
        self.titleLabel.textColor = .lisboaGray
    }
    
    func setIdentifiers(isLastMovements: Bool) {
        self.titleLabel.accessibilityIdentifier = AccesibilityLastMovementsList.titleHeader
        self.numberOfMovementsLabel.accessibilityIdentifier = isLastMovements
            ? AccesibilityLastMovementsList.lastMovementsDescriptionHeader
            : AccesibilityLastMovementsList.fractionablePaymentsDescriptionHeader
    }
    
    func attributedNumberOfMovements(_ numberOfMovements: Int, isSmallList: Bool, section: LastMovementsConfiguration.FractionableSection) -> NSAttributedString {
        var localizedText: LocalizedStylableText
        if isSmallList {
            localizedText = numberOfMovements == 1
            ? localized("pgBasket_label_transaction_one")
            : localized("pgBasket_label_transaction_other")
        } else {
            switch section {
            case .lastMovements:
                localizedText = numberOfMovements == 1
                    ? localized("whatsNew_label_newTransaction_one")
                    : localized("whatsNew_label_newTransaction_other")
            case .fundableAccounts, .fractionableCards:
                localizedText = numberOfMovements == 1
                    ? localized("whatsNew_label_fractionalPayments_one")
                    : localized("whatsNew_label_fractionalPayments_other")
            }
        }
        
        let whiteSpace = " "
        let optionalSeparatorString = isSmallList ? "|" : ""
        let numberOfItems = "\(numberOfMovements)"
        let title = optionalSeparatorString + whiteSpace + numberOfItems + whiteSpace + localizedText.text
        return attributedText(title, numberOfItems, isSmallList)
    }
    
    func attributedText(_ string: String, _ numberOfMovementsString: String, _ isSmallList: Bool) -> NSAttributedString {
        let fontSize: CGFloat = isSmallList ? 14.0 : 20.0
        let font = UIFont.santander(family: .text, type: .regular, size: fontSize)
        let attributedString = NSMutableAttributedString(string: string, attributes: [
          .font: font,
          .foregroundColor: UIColor.grafite
        ])
        attributedString.addAttributes([
          .font: UIFont.santander(family: .text, type: .bold, size: fontSize),
          .foregroundColor: UIColor.santanderRed
        ], range: NSRange(location: 0, length: numberOfMovementsString.count + 2))
        if isSmallList {
            attributedString.addAttributes([
                .font: font,
                .foregroundColor: UIColor.grafite
            ], range: NSRange(location: 0, length: 1))
        }
        return attributedString
    }
}
