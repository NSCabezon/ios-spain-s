//
//  StatusBranchTableViewCell.swift
//  LocatorApp
//
//  Created by vectoradmin on 13/8/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import UIKit

class StatusBranchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var dotView: UIView! {
        didSet {
            dotView.layer.cornerRadius = dotView.frame.width / 2
        }
    }
    @IBOutlet weak var lineView: UIView! {
        didSet {
            lineView.backgroundColor = DetailCardCellAndViewThemeColor.tableViewSeperators.value
        }
    }
}
