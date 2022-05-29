//
//  BasicServicesTableViewCell.swift
//  Alamofire
//
//  Created by Ivan Cabezon on 20/9/18.
//

import UIKit

class BasicServicesTableViewCell: UITableViewCell {
	
	@IBOutlet weak var iconBackgroundView: UIView! {
		didSet {
			iconBackgroundView.backgroundColor = DetailCardCellAndViewThemeColor.iconBackgrounds.value
		}
	}
	@IBOutlet weak var iconImageView: UIImageView! {
		didSet {
			iconImageView.tintColor = DetailCardCellAndViewThemeColor.iconTints.value
			iconImageView.image = UIImage(resourceName: "basicServices")
		}
	}
	
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.font = DetailCardCellAndViewThemeFont.headliners.value
			titleLabel.textColor = DetailCardCellAndViewThemeColor.headliners.value
			titleLabel.text = localizedString("bl_basic_services").capitalizingFirstLetter()
		}
	}

	@IBOutlet weak var subtitleLabel: UILabel! {
		didSet {
			subtitleLabel.font = DetailCardCellAndViewThemeFont.subHeadings.value
			subtitleLabel.textColor = DetailCardCellAndViewThemeColor.subHeadings.value
		}
	}
	
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
	
	func configure(with basicServices: [String]) {
		subtitleLabel.text = basicServices.joined(separator: "\n").toUppercaseAtSentenceBoundary()
	}
}
