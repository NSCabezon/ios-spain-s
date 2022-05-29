//
//  AdditionalServicesTableViewCell.swift
//  LocatorApp
//
//  Created by Ivan Cabezon on 27/8/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import UIKit

class AdditionalServicesTableViewCell: UITableViewCell {
	
	@IBOutlet weak var iconBackgroundView: UIView! {
		didSet {
			iconBackgroundView.backgroundColor = DetailCardCellAndViewThemeColor.iconBackgrounds.value
		}
	}
	@IBOutlet weak var iconImageView: UIImageView! {
		didSet {
			    iconImageView.tintColor = DetailCardCellAndViewThemeColor.iconTints.value
			iconImageView.image = UIImage(resourceName: "additionalServicesIcon")
		}
	}
	
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.font = DetailCardCellAndViewThemeFont.headliners.value
			titleLabel.textColor = DetailCardCellAndViewThemeColor.headliners.value
			titleLabel.text = localizedString("bl_additional_services").capitalizingFirstLetter()
		}
	}
	
	@IBOutlet weak var subtitleLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = DetailCardCellAndViewThemeColor.iconBackgrounds.value
		selectionStyle = .none
    }
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
//        iconBackgroundView.layer.cornerRadius = iconBackgroundView.bounds.height / 2
//        iconBackgroundView.layer.masksToBounds = true
	}
	
	func configure(with additionalServices: AdditionalServices?) {
		let attrsForTitle: [NSAttributedString.Key: Any] = [.font: DetailCardCellAndViewThemeFont.subHeadings.value, .foregroundColor: DetailCardCellAndViewThemeColor.subHeadings.value]
		let attrsForBody: [NSAttributedString.Key: Any] = [.font: DetailCardCellAndViewThemeFont.bodyText.value, .foregroundColor: DetailCardCellAndViewThemeColor.bodyText.value]
		
		let attrString = NSMutableAttributedString(string: "")
		
		if let atmServices = additionalServices?.atmAditionalServices {
			if atmServices.count > 0 {
				let servicesString = atmServices.joined(separator: "\n")
				attrString.append(NSAttributedString(string: servicesString, attributes: attrsForTitle))
			}
		} else {
			if let financialServices = additionalServices?.financial {
				if financialServices.count > 0 {
					attrString.append(NSMutableAttributedString(string: localizedString("bl_financial"), attributes: attrsForTitle))
					attrString.append(NSAttributedString(string: "\n"))
					attrString.append(NSAttributedString(string: financialServices.joined(separator: "\n").toUppercaseAtSentenceBoundary(), attributes: attrsForBody))
					attrString.append(NSAttributedString(string: "\n"))
				}
			}
			
			if let nonFinancialServices = additionalServices?.nonFinancial {
				if nonFinancialServices.count > 0 {
					if let financial = additionalServices?.financial {
						if financial.count > 0 {
							attrString.append(NSAttributedString(string: "\n"))
						}
					}
					attrString.append(NSMutableAttributedString(string: localizedString("bl_non_financial"), attributes: attrsForTitle))
					attrString.append(NSAttributedString(string: "\n"))
					attrString.append(NSAttributedString(string: nonFinancialServices.joined(separator: "\n"), attributes: attrsForBody))
				}
			}
		}
		subtitleLabel.attributedText = attrString.trailingNewlineChopped
	}
}
