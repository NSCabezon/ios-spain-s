//
//  AccessibilityTableViewCell.swift
//  LocatorApp
//
//  Created by Ivan Cabezon on 27/8/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import UIKit
import CoreFoundationLib

class AccessibilityTableViewCell: UITableViewCell {
	@IBOutlet weak var iconBackgroundView: UIView! {
		didSet {
			iconBackgroundView.backgroundColor = DetailCardCellAndViewThemeColor.iconBackgrounds.value
		}
	}
    @IBOutlet weak var iconImageView: UIImageView! {
        didSet {
            iconImageView.tintColor = DetailCardCellAndViewThemeColor.iconTints.value
			iconImageView.image = UIImage(resourceName: "accesibilityIcon")
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = DetailCardCellAndViewThemeFont.headliners.value
            titleLabel.textColor = DetailCardCellAndViewThemeColor.headliners.value
            titleLabel.text = localizedString("bl_accessibility").capitalizingFirstLetter()
        }
    }
    
    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = DetailCardCellAndViewThemeFont.subHeadings.value
            subtitleLabel.textColor = DetailCardCellAndViewThemeColor.subHeadings.value
            subtitleLabel.text = localizedString("bl_accessibility_handicaped").capitalizingFirstLetter()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
		
//        iconBackgroundView.layer.cornerRadius = iconBackgroundView.bounds.height / 2
//        iconBackgroundView.layer.masksToBounds = true
		
		selectionStyle = .none
    }
	
	func configure(withAudioguidanceTextVisible audioguidanceTextIsVisible: Bool) {
		if audioguidanceTextIsVisible {
			var text = localizedString("bl_audio_guidance").appending("\n").uppercased()
			text.append(localizedString("bl_accessibility_handicaped").uppercased())
			subtitleLabel.text = text
		}
	}
}
