//
//  LastBillLoadingTableViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/25/20.
//

import UIKit
import CoreFoundationLib

class LastBillLoadingTableViewCell: UITableViewCell {
    static let identifier: String = "LastBillLoadingTableViewCell"
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var loadingDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.appearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.loadingImageView.setPointsLoader()
    }
}

private extension LastBillLoadingTableViewCell {
    func appearance() {
        self.loadingImageView.setPointsLoader()
        self.loadingDescriptionLabel.textColor = .lisboaGray
        self.loadingDescriptionLabel.configureText(withKey: "generic_popup_loadingContent")
    }
}
