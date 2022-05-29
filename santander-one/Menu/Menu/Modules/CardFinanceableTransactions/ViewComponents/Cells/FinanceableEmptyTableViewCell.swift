//
//  FinanceableEmptyTableViewCell.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 6/26/20.
//

import UIKit
import UI

class FinanceableEmptyTableViewCell: UITableViewCell {
    static let identifier = "FinanceableEmptyTableViewCell"
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var leavesImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.descriptionLabel.configureText(withKey: "financing_text_emptyView")
        self.leavesImageView.image = Assets.image(named: "imgLeaves")
    }
}
