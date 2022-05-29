//
//  ScheduleCashTableViewCell.swift
//  BranchLocator
//
//  Created by kevin Sabajanes on 21/01/2020.
//  Copyright © 2020 Globile. All rights reserved.
//

import UIKit

class ScheduleCashTableViewCell: UITableViewCell {
    
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
            titleLabel.text = localizedString("bl_schedule_cash").capitalizingFirstLetter()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = DetailCardCellAndViewThemeColor.iconBackgrounds.value
        selectionStyle = .none
    }
    
    func configure(with scheduleCashStringDict: [String]? ) {

        
        for view in variableContentView.subviews {
            view.removeFromSuperview()
        }
        
        guard let compounds = scheduleCashStringDict else {
            return
        }
        
        var label: UILabel
                for hour in compounds {
                    label = UILabel(frame: CGRect(x: 0, y: 0, width: variableContentView.frame.width, height: 0))
                    label.numberOfLines = 0
                    label.text = hour
                    label.font = DetailCardCellAndViewThemeFont.subHeadings.value
                    label.textColor = DetailCardCellAndViewThemeColor.subHeadings.value
                    variableContentView.addArrangedSubview(label)
            }
    }
}
