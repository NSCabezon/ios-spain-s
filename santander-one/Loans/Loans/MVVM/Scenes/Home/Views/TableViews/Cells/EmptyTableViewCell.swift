//
//  LastBillEmptyTableViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/19/20.
//

import UIKit
import CoreFoundationLib
import UI

final class EmptyTableViewCell: UITableViewCell {
    static let identifier: String = "EmptyTableViewCell"
    @IBOutlet weak private var emptyImageVeiw: UIImageView!
    @IBOutlet weak private var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.appearance()
    }
    
    func configure(with error: LocalizedError?) {
        let errorKey = error?.errorDescription ?? "generic_label_emptyNotAvailableMoves"
        self.descriptionLabel.configureText(withKey: errorKey)
    }
}

private extension EmptyTableViewCell {
    func appearance() {
        self.emptyImageVeiw.image = Assets.image(named: "imgLeaves")
        self.descriptionLabel.font = .santander(family: .text, type: .italic, size: 18)
        self.descriptionLabel.configureText(withKey: "generic_label_emptyNotAvailableMoves")
        self.descriptionLabel.accessibilityIdentifier = "generic_label_emptyNotAvailableMoves"
        self.descriptionLabel.textColor = .lisboaGray
    }
}
