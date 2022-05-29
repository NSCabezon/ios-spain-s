//
//  ProductElementTableViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/2/20.
//

import UI
import CoreFoundationLib

class ProductElementTableViewCell: UITableViewCell {
    static let identifier = "ProductElementTableViewCell"
    @IBOutlet var rightLeftLines: [UIView]!
    @IBOutlet weak var grayBoxView: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var transmitterLabel: UILabel!
    @IBOutlet weak var lastBillsDateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var billsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppearance()
        self.setAccessibilityIdentifiers()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.setAppearance()
        self.setAccessibilityIdentifiers()
    }
    
    func setViewModel(_ viewModel: TransmitterGroupViewModel) {
        self.transmitterLabel.text = viewModel.name
        self.lastBillsDateLabel.configureText(withLocalizedString: viewModel.dateLocalized,
                                              andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 12),
                                                                                                   lineHeightMultiple: 0.75))
        self.amountLabel.attributedText = viewModel.amount
        self.billsLabel.configureText(withLocalizedString: viewModel.billNumberLocalized)
    }
    
    func setAppearance() {
        self.viewContainer.backgroundColor = .white
        self.contentView.backgroundColor = .white
        self.grayBoxView.backgroundColor = .skyGray
        self.rightLeftLines.forEach { $0.backgroundColor = .lightSkyBlue}
        self.viewContainer.drawRoundedAndShadowedNew(radius: 6, borderColor: .lightSkyBlue)
    }
}

private extension ProductElementTableViewCell {
    private func setAccessibilityIdentifiers() {
        self.transmitterLabel.accessibilityIdentifier = AccesibilityBills.LastBillProductElementView.lastBillProductTitleTextView
        self.lastBillsDateLabel.accessibilityIdentifier = AccesibilityBills.LastBillProductElementView.lastBillProductDateTextView
        self.amountLabel.accessibilityIdentifier = AccesibilityBills.LastBillProductElementView.lastBillProductTotalAmountTextView
        self.billsLabel.accessibilityIdentifier = AccesibilityBills.LastBillProductElementView.billsAndTaxesPaymentCounterTextView
    }
}
