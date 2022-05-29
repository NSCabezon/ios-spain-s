//
//  TransmitterTableViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 3/12/20.
//

import UIKit
import CoreFoundationLib

class TransmitterElementTableViewCell: UITableViewCell {
    static let identifier: String = "TransmitterElementTableViewCell"
    @IBOutlet weak var billDateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var boxView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setBorder()
        self.boxView.backgroundColor = UIColor.skyGray
        self.setAccessibilityIdentifiers()
    }
    
    func setViewModel(_ viewModel: LastBillViewModel) {
        self.billDateLabel.configureText(withLocalizedString: viewModel.dateLocalized)
        self.amountLabel.attributedText = viewModel.amountAttributedText
    }
}

private extension TransmitterElementTableViewCell {
    func setBorder() {
        self.viewContainer.drawBorder(cornerRadius: 6, color: .lightSkyBlue, width: 1)
        self.viewContainer.drawRoundedAndShadowedNew()
    }
    
    func setAccessibilityIdentifiers() {
        self.billDateLabel.accessibilityIdentifier = AccesibilityBills.TransmitterElementView.lastBillCardViewIssuingItemDateTextView
        self.amountLabel.accessibilityIdentifier = AccesibilityBills.TransmitterElementView.lastBillCardViewIssuingItemAmountText
    }
}
