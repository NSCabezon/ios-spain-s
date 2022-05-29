//
//  FilterTableViewCell.swift
//  LocatorApp
//
//  Created by Santander on 17/08/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var icon: FilterSelection!
	@IBOutlet weak var title: UILabel! {
		didSet {
			title.textColor = .mediumSanGray
		}
	}
    
    public var selectedFont = UIFont.santander(family: .text, type: .bold, size: 18)
    public var unselectedFont = UIFont.santander(family: .text, type: .regular, size: 18)
    public var selectedIcon = UIImage()
    public var unselectedIcon = UIImage()
    public var currentFilter: Filter?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configureCell(with result: Filter) {
        title.text = result.title
        selectedIcon = result.icon(selected: true)
        unselectedIcon = result.icon(selected: false)
        currentFilter = result
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            icon.icon.image = selectedIcon
            icon.tintColor = .santanderRed
            title.font = selectedFont
            //MODO ANTERIOR
            /*if currentFilter == Filter.workcafe {
                icon.changeColors(bgView: UIColor.darkGrey, border: UIColor.darkGrey.cgColor)
            } else {*/
                icon.changeColors(bgView: FilterTableViewCellColor.iconSelectedBackground.value, border: FilterTableViewCellColor.iconBorderSelected.value.cgColor)
            //}
            self.backgroundColor = FilterTableViewCellColor.tableViewCellBackground.value
        } else {
            icon.icon.image = unselectedIcon
            icon.tintColor = .mediumSanGray
            title.font = unselectedFont
            icon.changeColors(bgView: FilterTableViewCellColor.tableViewCellBackground.value, border: FilterTableViewCellColor.iconBorderUnselected.value.cgColor)
            self.backgroundColor = FilterTableViewCellColor.tableViewCellBackground.value
        }
    }
}
