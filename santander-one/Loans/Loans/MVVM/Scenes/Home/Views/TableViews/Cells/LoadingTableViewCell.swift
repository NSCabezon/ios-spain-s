//
//  LastBillLoadingTableViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/25/20.
//

import UIKit
import UI
import CoreFoundationLib

final class LoadingTableViewCell: UITableViewCell {
    @IBOutlet weak private var loadingImageView: UIImageView!
    @IBOutlet weak private var loadingDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.appearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.loadingImageView.setPointsLoader()
    }
    
    func setIdentifiers(label: String, image: String) {
        loadingDescriptionLabel.accessibilityIdentifier = label
        loadingImageView.isAccessibilityElement = true
        loadingImageView.accessibilityIdentifier = image
    }
}

private extension LoadingTableViewCell {
    func appearance() {
        self.loadingImageView.setPointsLoader()
        self.loadingDescriptionLabel.textColor = .lisboaGray
        self.loadingDescriptionLabel.configureText(withKey: "loading_label_transactionsLoading")
    }
}
