//
//  PeriodicTransferTableViewCell.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 10/02/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class PeriodicTransferTableViewCell: UITableViewCell {
    @IBOutlet private weak var conceptLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var topDottedLineView: DottedLineView!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: .module)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        self.conceptLabel.text = nil
        self.dateLabel.text = nil
        self.amountLabel.text = nil
        self.topDottedLineView.isHidden = true
    }
    
    // MARK: - Public
    func setViewModel(_ viewModel: PeriodicTransferViewModelProtocol) {
        self.conceptLabel.text = viewModel.concept
        if let date = viewModel.dateDescription {
            self.dateLabel.configureText(withLocalizedString: date)
        }
        self.amountLabel.attributedText = viewModel.amountAttributedString
        self.topDottedLineView.isHidden = viewModel.isTopSeparatorHidden
        self.topConstraint.constant = viewModel.isTopSeparatorHidden ? 9.0 : 11.0
    }
}

private extension PeriodicTransferTableViewCell {
    // MARK: - Setup cell
    func configureView() {
        self.configureLabels()
        self.selectionStyle = .none
        self.setAccessibilityIdentifiers()
    }
    
    func configureLabels() {
        self.conceptLabel.font = UIFont.santander(family: .text, type: .bold, size: 16)
        self.conceptLabel.textColor = .lisboaGray
        self.dateLabel.font = UIFont.santander(family: .text, type: .light, size: 14)
        self.dateLabel.textColor = .mediumSanGray
        self.amountLabel.textAlignment = .right
        self.amountLabel.textColor = .lisboaGray
        self.topDottedLineView.isHidden = true
    }
    
    func setAccessibilityIdentifiers() {
        self.conceptLabel.accessibilityIdentifier = ScheduledTransfersListAccessibilityIdentifier.scheduledTransfersPeriodicConcept
        self.dateLabel.accessibilityIdentifier = ScheduledTransfersListAccessibilityIdentifier.scheduledTransfersPeriodicDate
        self.amountLabel.accessibilityIdentifier = ScheduledTransfersListAccessibilityIdentifier.scheduledTransfersPeriodicAmount
        self.accessibilityIdentifier = ScheduledTransfersListAccessibilityIdentifier.scheduledTransfersPeriodicTransferCell
    }
}
