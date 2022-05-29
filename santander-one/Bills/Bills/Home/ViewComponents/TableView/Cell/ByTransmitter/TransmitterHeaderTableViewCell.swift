//
//  TransmitterGroupTableViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 3/12/20.
//

import UIKit
import UI
import CoreFoundationLib

protocol TransmitterHeaderTableViewCellDelegate: AnyObject {
    func didSelectTransmitterHeaderCell(_ cell: TransmitterHeaderTableViewCell)
}

class TransmitterHeaderTableViewCell: UITableViewCell {
    static let identifier: String = "TransmitterHeaderTableViewCell"
    @IBOutlet weak var transmitterLabel: UILabel!
    @IBOutlet weak var lastBillsDateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var billsLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var originAccountImageView: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var hideBorderButtomView: UIView!
    weak var delegate: TransmitterHeaderTableViewCellDelegate?
    private var viewModel: TransmitterGroupViewModel?
    
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
        self.viewModel = viewModel
        self.transmitterLabel.text = viewModel.name
        self.lastBillsDateLabel.configureText(withLocalizedString: viewModel.dateLocalized)
        self.amountLabel.attributedText = viewModel.amount
        self.accountNumberLabel.text = viewModel.accountNumber
        self.billsLabel.configureText(withLocalizedString: viewModel.billNumberLocalized)
        self.originAccountImageView.image = Assets.image(named: "icn_santander_cards")
        self.setAppearance()
        self.setBorder()
    }
    
    @IBAction func didSelectExpandOrCollapse(_ sender: Any) {
        self.viewModel?.toggle()
        self.delegate?.didSelectTransmitterHeaderCell(self)
    }
}

private extension TransmitterHeaderTableViewCell {
    func setAppearance() {
        self.arrowImageView.image = Assets.image(named: "icnArrowDownSlim")
        self.hideBorderButtomView.backgroundColor = .skyGray
        if let viewModel = self.viewModel, viewModel.isExpanded {
            self.setExpandedAppearance()
        } else {
            self.setCollapsedAppearance()
        }
    }
    
    func setExpandedAppearance() {
        self.viewContainer.backgroundColor = UIColor.skyGray
        self.hideBorderButtomView.isHidden = false
        self.arrowImageView.transform = CGAffineTransform(rotationAngle: .pi)
    }
    
    func setCollapsedAppearance() {
        self.viewContainer.backgroundColor = UIColor.white
        self.hideBorderButtomView.isHidden = true
        self.arrowImageView.transform = .identity
    }
    
    func setBorder() {
        self.viewContainer.drawRoundedAndShadowedNew(radius: 6, borderColor: .lightSkyBlue)
    }
    
    func setAccessibilityIdentifiers() {
        self.transmitterLabel.accessibilityIdentifier = AccesibilityBills.TransmitterHeaderView.lastBillIssuingTitleTextView
        self.lastBillsDateLabel.accessibilityIdentifier = AccesibilityBills.TransmitterHeaderView.lastBillIssuingLastDateTextView
        self.amountLabel.accessibilityIdentifier = AccesibilityBills.TransmitterHeaderView.lastBillIssuingTotalAmountTextView
        self.billsLabel.accessibilityIdentifier = AccesibilityBills.TransmitterHeaderView.receiptsAndTaxesReceipsCounterTextView
        self.accountNumberLabel.accessibilityIdentifier = AccesibilityBills.TransmitterHeaderView.lastBillIssuingAccountTextView
        self.originAccountImageView.accessibilityIdentifier = AccesibilityBills.TransmitterHeaderView.lastBillIssuingBankImageView
    }
}
