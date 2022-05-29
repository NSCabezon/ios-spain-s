//
//  PhoneCell.swift
//  LocatorApp
//
//  Created by vectoradmin on 27/8/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import UIKit

class PhoneCell: UITableViewCell {
	@IBOutlet weak var iconBackgroundView: UIView! {
		didSet {
			iconBackgroundView.backgroundColor = DetailCardCellAndViewThemeColor.iconBackgrounds.value
		}
	}
	@IBOutlet weak var iconImageView: UIImageView! {
		didSet {
			iconImageView.tintColor = DetailCardCellAndViewThemeColor.iconTints.value
			iconImageView.image = UIImage(resourceName: "phoneIcon")
		}
	}
	
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = DetailCardCellAndViewThemeFont.headliners.value
            titleLabel.textColor = DetailCardCellAndViewThemeColor.headliners.value
            titleLabel.text = localizedString("bl_phone").capitalizingFirstLetter()
        }
    }
    @IBOutlet weak var detailLabel: UILabel! {
        didSet {
            detailLabel.font = DetailCardCellAndViewThemeFont.bodyText.value
            detailLabel.textColor = DetailCardCellAndViewThemeColor.bodyText.value
        }
    }
    
    @IBOutlet weak var callButton: GlobileEndingButton! {
        didSet {
            callButton.layer.cornerRadius = callButton.frame.height / 2
            callButton.isPrimary = false
            callButton.setTitle(localizedString("bl_call").capitalizingFirstLetter(), for: .normal)
        }
    }
    
	override func awakeFromNib() {
		super.awakeFromNib()
		self.backgroundColor = DetailCardCellAndViewThemeColor.iconBackgrounds.value
		selectionStyle = .none
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		callButton.layer.cornerRadius = callButton.bounds.height / 2
		callButton.layer.masksToBounds = true
	}
}
