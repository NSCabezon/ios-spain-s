//
//  MenuSectionTitleTableViewCell.swift
//  RetailClean
//
//  Created by Carlos Gutiérrez Casado on 28/05/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import UIKit

class MenuSectionTitleTableViewCell: BaseViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.setSantanderTextFont(type: .bold, size: 13.0, color: .grafite)
    }    
}
