//
//  ScheduledTransferTableViewCell.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 04/02/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class ScheduledTransferTableViewCell: UITableViewCell {
    @IBOutlet private weak var conceptLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var topDottedLineView: DottedLineView!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: .module)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        self.conceptLabel.text = nil
        self.descriptionLabel.text = nil
        self.amountLabel.text = nil
        self.topDottedLineView.isHidden = true
    }
    
    // MARK: - Public
    func setViewModel(_ viewModel: ScheduledTransferViewModelProtocol) {
        self.conceptLabel.text = viewModel.concept
        self.descriptionLabel.text = viewModel.date
        self.amountLabel.attributedText = viewModel.amountAttributedString
        self.topDottedLineView.isHidden = viewModel.isTopSeparatorHidden
        self.topConstraint.constant = viewModel.isTopSeparatorHidden ? 9.0 : 11.0
    }
}
    
private extension ScheduledTransferTableViewCell {
    // MARK: - Setup cell
    func configureView() {
        self.configureLabels()
        self.selectionStyle = .none
        self.setAccessibilityIdentifiers()
    }
    
    func configureLabels() {
        self.conceptLabel.font = UIFont.santander(family: .text, type: .bold, size: 16)
        self.conceptLabel.textColor = .lisboaGray
        self.descriptionLabel.font = UIFont.santander(family: .text, type: .light, size: 14)
        self.descriptionLabel.textColor = .mediumSanGray
        self.amountLabel.textAlignment = .right
        self.amountLabel.textColor = .lisboaGray
        self.topDottedLineView.isHidden = true
    }
    
    func setAccessibilityIdentifiers() {
        self.conceptLabel.accessibilityIdentifier = ScheduledTransfersListAccessibilityIdentifier.scheduledTransfersScheduledConcept
        self.descriptionLabel.accessibilityIdentifier = ScheduledTransfersListAccessibilityIdentifier.scheduledTransfersScheduledDescription
        self.amountLabel.accessibilityIdentifier = ScheduledTransfersListAccessibilityIdentifier.scheduledTransfersScheduledAmount
        self.accessibilityIdentifier = ScheduledTransfersListAccessibilityIdentifier.scheduledTransfersScheduledTransferCell
    }
}
