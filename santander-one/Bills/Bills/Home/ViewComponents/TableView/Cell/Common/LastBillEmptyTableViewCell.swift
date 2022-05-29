//
//  LastBillEmptyTableViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/19/20.
//

import UIKit
import CoreFoundationLib
import UI

class LastBillEmptyTableViewCell: UITableViewCell {
    static let identifier: String = "LastBillEmptyTableViewCell"
    @IBOutlet weak var emptyImageVeiw: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.appearance()
        self.setAccessibilityIdentifiers()
    }
}

private extension LastBillEmptyTableViewCell {
    func appearance() {
        self.emptyImageVeiw.image = Assets.image(named: "imgLeaves")
        self.titleLabel.configureText(withKey: "transfer_title_emptyView_recent")
        self.descriptionLabel.configureText(withKey: "receiptsAndTaxes_textEmpty_lastReceipts")
        self.descriptionLabel.textColor = .brownishGray
        self.titleLabel.textColor = .lisboaGray
    }
    
    private func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccesibilityBills.LastBillEmptyView.lastBillTitleTextView
        self.descriptionLabel.accessibilityIdentifier = AccesibilityBills.LastBillEmptyView.lastBillMessageTextView
    }
    
}
