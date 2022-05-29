//
//  TransmitterGroupView.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/7/20.
//

import Foundation
import UI
import CoreFoundationLib

final class TransmitterHeaderView: XibView {
    @IBOutlet weak var transmitterLabel: UILabel!
    @IBOutlet weak var lastBillsDateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var billsLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var originAccountImageView: UIImageView!
    
    func setViewModel(_ viewModel: TransmitterGroupViewModel) {
        self.transmitterLabel.text = viewModel.name
        self.lastBillsDateLabel.configureText(withLocalizedString: viewModel.dateLocalized)
        self.amountLabel.attributedText = viewModel.amount
        self.accountNumberLabel.text = viewModel.accountNumber
        self.billsLabel.configureText(withLocalizedString: viewModel.billNumberLocalized)
        self.originAccountImageView.image = Assets.image(named: "icn_santander_cards")
        self.transmitterLabel.configureText(withLocalizedString: LocalizedStylableText(text: viewModel.name, styles: nil),
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 18),
                                                                                                 lineHeightMultiple: 0.75))
        self.setAccessibilityIdentifiers()
    }
}

private extension TransmitterHeaderView {
    func setAccessibilityIdentifiers() {
        self.transmitterLabel.accessibilityIdentifier = AccesibilityBills.TransmitterHeaderView.lastBillIssuingTitleTextView
        self.lastBillsDateLabel.accessibilityIdentifier = AccesibilityBills.TransmitterHeaderView.lastBillIssuingLastDateTextView
        self.amountLabel.accessibilityIdentifier = AccesibilityBills.TransmitterHeaderView.lastBillIssuingTotalAmountTextView
        self.billsLabel.accessibilityIdentifier = AccesibilityBills.TransmitterHeaderView.receiptsAndTaxesReceipsCounterTextView
        self.accountNumberLabel.accessibilityIdentifier = AccesibilityBills.TransmitterHeaderView.lastBillIssuingAccountTextView
        self.originAccountImageView.accessibilityIdentifier = AccesibilityBills.TransmitterHeaderView.lastBillIssuingBankImageView
    }
}
