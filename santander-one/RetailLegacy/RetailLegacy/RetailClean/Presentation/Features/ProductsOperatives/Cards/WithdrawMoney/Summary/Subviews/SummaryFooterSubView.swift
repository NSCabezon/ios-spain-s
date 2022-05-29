//
//  SummaryFooterSubView.swift
//  RetailClean
//
//  Created by David Gálvez Alonso on 25/02/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import UIKit
import UI

class SummaryFooterSubView: DesignableView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImageview: UIImageView!
    var action: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        titleLabel.textColor = UIColor.white
    }
    
    @IBAction func touchItem() {
        action?()
    }
}
