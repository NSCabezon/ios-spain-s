//
//  CardFinanceableTransactionsHeaderView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 06/07/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol CardFinanceableTransactionsHeaderViewDelegate: AnyObject {
    func didSelectSeeAllFinanceableTransactions()
}

class CardFinanceableTransactionsHeaderView: XibView {
    @IBOutlet weak var cardsLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    
    weak var delegate: CardFinanceableTransactionsHeaderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    @IBAction func seeAllButtonPressed(_ sender: UIButton) {
        self.delegate?.didSelectSeeAllFinanceableTransactions()
    }
    
    func setSeeAllButtonHidden(_ isHidden: Bool) {
        self.seeAllButton.isHidden = isHidden
    }
}

private extension CardFinanceableTransactionsHeaderView {
    func setAppearance() {
        self.setLabel()
        self.setButton()
        self.setAccessibilityIdentifiers()
    }
    
    func setLabel() {
        self.cardsLabel.text = localized("financing_title_cards")
        self.cardsLabel.font = .santander(family: .text, type: .bold, size: 14)
        self.cardsLabel.textColor = .lisboaGray
    }
    
    func setButton() {
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.darkTorquoise
        attributes[.font] = UIFont.santander(family: .text, type: .regular, size: 14)
        let attributedString = NSAttributedString(string: localized("financing_button_seeAll"), attributes: attributes)
        self.seeAllButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    func setAccessibilityIdentifiers() {
        self.cardsLabel.accessibilityIdentifier = AccessibilityFinancingCardCarousel.titleAccounts
        self.seeAllButton.accessibilityIdentifier = AccessibilityFinancingCardCarousel.btnSeeAll
    }
}
