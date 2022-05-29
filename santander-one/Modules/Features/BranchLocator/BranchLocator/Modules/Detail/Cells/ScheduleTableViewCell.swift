//
//  ScheduleTableViewCell.swift
//  LocatorApp
//
//  Created by Ivan Cabezon on 27/8/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
	
    @IBOutlet var variableContentView: UIStackView!
    
    @IBOutlet weak var iconBackgroundView: UIView! {
		didSet {
			iconBackgroundView.backgroundColor = DetailCardCellAndViewThemeColor.iconBackgrounds.value
		}
	}
	@IBOutlet weak var iconImageView: UIImageView! {
		didSet {
			iconImageView.tintColor = DetailCardCellAndViewThemeColor.iconTints.value
			iconImageView.image = UIImage(resourceName: "scheduleIcon")
		}
	}
	
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.font = DetailCardCellAndViewThemeFont.headliners.value
			titleLabel.textColor = DetailCardCellAndViewThemeColor.headliners.value
			titleLabel.text = localizedString("bl_schedule").capitalizingFirstLetter()
		}
	}
	
	@IBOutlet weak var subtitleLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
        self.backgroundColor = DetailCardCellAndViewThemeColor.iconBackgrounds.value
		selectionStyle = .none
	}
	
	func configure(with scheduleString: NSAttributedString?) {
		//subtitleLabel.attributedText = scheduleString
	}
    
    func configure(with scheduleStringDict: [ScheduleDay]? ) {
        var customView: ScheduleCustomView
        for view in variableContentView.subviews {
            view.removeFromSuperview()
        }
        
        guard let compounds = scheduleStringDict else {
            return
        }
        
        for day in compounds {
            
            customView = ScheduleCustomView.init()
            customView.setupHours(hours: day.times)
            customView.titleLabel.text = day.date ?? ""
            customView.titleLabel.font = DetailCardCellAndViewThemeFont.subHeadings.value
            customView.titleLabel.textColor = DetailCardCellAndViewThemeColor.subHeadings.value
            
            variableContentView.addArrangedSubview(customView)
        }
    }

	override func layoutSubviews() {
		super.layoutSubviews()
//        iconBackgroundView.layer.cornerRadius = iconBackgroundView.bounds.height / 2
//        iconBackgroundView.layer.masksToBounds = true
	}
    

}
