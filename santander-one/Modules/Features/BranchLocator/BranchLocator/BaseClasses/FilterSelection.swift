//
//  FilterSelection.swift
//  LocatorApp
//
//  Created by Santander on 24/08/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import UIKit

class FilterSelection: UIView {
    
    @IBOutlet weak var icon: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureUi()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUi()
    }
    
    func configureUi() {
        self.layer.cornerRadius = 2
        self.layer.borderWidth = 2
        self.layer.borderColor = FilterTableViewCellColor.iconBorderUnselected.value.cgColor
        self.backgroundColor = FilterTableViewCellColor.tableViewCellBackground.value
    }
    
    func changeColors(bgView: UIColor, border: CGColor) {
        self.backgroundColor = bgView
        self.layer.borderColor = border
    }
    
}
