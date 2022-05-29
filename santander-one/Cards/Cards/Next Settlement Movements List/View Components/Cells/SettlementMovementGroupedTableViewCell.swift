//
//  SettlementMovementGroupedTableViewCell.swift
//  Cards
//
//  Created by David Gálvez Alonso on 19/10/2020.
//

import UIKit
import CoreFoundationLib

final class SettlementMovementGroupedTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
    public static let identifier = "SettlementMovementGroupedTableViewCell"
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    func configureCell(_ viewModel: NextSettlementMovementViewModel) {
        self.descriptionLabel.text = viewModel.concept
        self.amountLabel.text = viewModel.amountText
    }
}

private extension SettlementMovementGroupedTableViewCell {
    func setupView() {
        self.backgroundColor = .clear
        self.descriptionLabel.font = UIFont.santander(family: .text, type: .bold, size: 14.0)
        self.descriptionLabel.textColor = .lisboaGray
        self.amountLabel.font = UIFont.santander(family: .text, type: .bold, size: 14.0)
        self.amountLabel.textColor = .lisboaGray
        self.separatorView.backgroundColor = .mediumSkyGray
        self.descriptionLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementMovements.nextSettlementMovementLabelDescription.rawValue
        self.amountLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementMovements.nextSettlementMovementLabelAmount.rawValue
    }
}
