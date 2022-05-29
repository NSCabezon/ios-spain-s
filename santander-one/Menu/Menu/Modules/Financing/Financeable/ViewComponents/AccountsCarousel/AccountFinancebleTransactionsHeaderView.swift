//
//  AccountFinancebleTransactionsHeaderView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 24/08/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol AccountFinanceableTransactionsHeaderViewDelegate: AnyObject {
    func didSelectSeeAllFinanceableTransactions()
}

class AccountFinanceableTransactionsHeaderView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    
    weak var delegate: AccountFinanceableTransactionsHeaderViewDelegate?
    
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

private extension AccountFinanceableTransactionsHeaderView {
    func setAppearance() {
        self.setLabel()
        self.setButton()
        self.setAccessibilityIdentifiers()
    }
    
    func setLabel() {
        self.titleLabel.text = localized("financing_label_accounts")
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 14)
        self.titleLabel.textColor = .lisboaGray
    }
    
    func setButton() {
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.darkTorquoise
        attributes[.font] = UIFont.santander(family: .text, type: .regular, size: 14)
        let attributedString = NSAttributedString(string: localized("financing_button_seeAll"), attributes: attributes)
        self.seeAllButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityFinancingAccountCarousel.titleAccounts
        self.seeAllButton.accessibilityIdentifier = AccessibilityFinancingAccountCarousel.btnSeeAll
    }
}
