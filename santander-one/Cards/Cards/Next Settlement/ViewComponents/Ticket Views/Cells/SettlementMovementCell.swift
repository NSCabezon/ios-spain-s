//
//  SettlementMovementCell.swift
//  Cards
//
//  Created by Laura González on 07/10/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class SettlementMovementCell: UIDesignableView {
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var conceptLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
    override func getBundleName() -> String {
        return "Cards"
    }
    
    override func commonInit() {
        super.commonInit()
        self.setupView()
        setAccessibilityIdentifiers()
    }
    
    func configureCell(_ viewModel: NextSettlementMovementViewModel) {
        self.dateLabel.text = viewModel.date
        self.conceptLabel.text = viewModel.concept
        self.amountLabel.text = viewModel.amountText
        self.isUserInteractionEnabled = false
    }
    
    func configureSeparator(_ isLastCell: Bool) {
        self.separatorView.isHidden = !isLastCell
        self.separatorView.backgroundColor = .mediumSkyGray
    }
}

private extension SettlementMovementCell {
    func setupView() {
        self.backgroundColor = .clear
        self.dateLabel.font = UIFont.santander(family: .text, type: .bold, size: 12.0)
        self.dateLabel.textColor = .mediumSanGray
        self.conceptLabel.font = UIFont.santander(family: .text, type: .bold, size: 14.0)
        self.conceptLabel.textColor = .lisboaGray
        self.amountLabel.font = UIFont.santander(family: .text, type: .bold, size: 14.0)
        self.amountLabel.textColor = .lisboaGray
    }
    
    func setAccessibilityIdentifiers() {
        dateLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.nextSettlementLabelCellDate.rawValue
        conceptLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.nextSettlementLabelCellConcept.rawValue
        amountLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementDetail.nextSettlementLabelCellAmount.rawValue
    }
}
