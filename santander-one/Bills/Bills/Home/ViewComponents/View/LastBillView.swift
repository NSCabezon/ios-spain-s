//
//  LastBillView.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/14/20.
//

import Foundation
import UI
import CoreFoundationLib

final class LastBillView: XibView {
    @IBOutlet weak var naneLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    
    func setViewModel(_ viewModel: LastBillViewModel) {
        self.naneLabel.text = viewModel.name
        self.accountLabel.text = viewModel.accountNumber
        self.amountLabel.attributedText = viewModel.amountAttributedText
        self.statusLabel.configureText(withLocalizedString: viewModel.billStatus.text)
        self.statusLabel.textColor = viewModel.billStatus.color
        self.statusView.drawBorder(cornerRadius: 2, color: viewModel.billStatus.color, width: 1)
        self.view?.drawBorder(cornerRadius: 4, color: .clear, width: 1)
        self.setAccessibilityIdentifiers()
    }
    
}

private extension LastBillView {
    private func setAccessibilityIdentifiers() {
        self.naneLabel.accessibilityIdentifier = AccesibilityBills.LastBillDateView.lastBillTitleTextView
        self.accountLabel.accessibilityIdentifier = AccesibilityBills.LastBillDateView.lastBillAccountTypeTextView
        self.amountLabel.accessibilityIdentifier = AccesibilityBills.LastBillDateView.lastBillAmountTextView
        self.statusLabel.accessibilityIdentifier = AccesibilityBills.LastBillDateView.lastBillStateTextView
    }
}
