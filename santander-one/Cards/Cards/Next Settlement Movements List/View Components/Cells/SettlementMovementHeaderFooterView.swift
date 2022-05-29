//
//  SettlementMovementHeaderFooterView.swift
//  Cards
//
//  Created by David Gálvez Alonso on 19/10/2020.
//

import UIKit
import CoreFoundationLib

final class SettlementMovementHeaderFooterView: UITableViewHeaderFooterView {
    @IBOutlet private weak var dateLabel: UILabel!
    
    public static let identifier = "SettlementMovementHeaderFooterView"

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func configureWithDate(_ date: String) {
        dateLabel.font = .santander(family: .text, type: .bold, size: 12)
        dateLabel.textColor = .mediumSanGray
        dateLabel.text = date
        dateLabel.accessibilityIdentifier = AccessibilityCardsNextSettlementMovements.nextSettlementMovementLabelDate.rawValue
    }
}

private extension SettlementMovementHeaderFooterView {
    func setupView() {
        self.tintColor = .white
    }
}
