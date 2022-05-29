//
//  EmitterLoadingTableViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/19/20.
//

import UIKit
import UI

class EmitterLoadingTableViewCell: UITableViewCell {
    static let identifier = "EmitterLoadingTableViewCell"
    @IBOutlet weak var titleLoading: UILabel!
    @IBOutlet weak var subTitleLoading: UILabel!
    @IBOutlet weak var loadintImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadintImageView.setPointsLoader()
        loadintImageView.clipsToBounds = false
        titleLoading.configureText(withKey: "generic_labelLoading_searching")
        subTitleLoading.configureText(withKey: "loading_label_moment", andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75))
    }
}
