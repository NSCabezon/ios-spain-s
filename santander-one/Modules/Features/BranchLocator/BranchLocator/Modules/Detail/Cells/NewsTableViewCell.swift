//
//  NewsTableViewCell.swift
//  LocatorApp
//
//  Created by Ivan Cabezon on 27/8/18.
//  Copyright © 2018 Globile. All rights reserved.
//

import UIKit

protocol NewsTableViewCellProtocol : class{
    func openURL(_ url: URL)
}

class NewsTableViewCell: UITableViewCell {
	
    weak var delegate: NewsTableViewCellProtocol?
    
	@IBOutlet weak var iconBackgroundView: UIView! {
		didSet {
			iconBackgroundView.backgroundColor = DetailCardCellAndViewThemeColor.iconBackgrounds.value
		}
	}
	@IBOutlet weak var iconImageView: UIImageView! {
		didSet {
			iconImageView.tintColor = DetailCardCellAndViewThemeColor.iconTints.value
			iconImageView.image = UIImage(resourceName: "newsIcon")
		}
	}
	
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.font = DetailCardCellAndViewThemeFont.headliners.value
			titleLabel.textColor = DetailCardCellAndViewThemeColor.headliners.value
			titleLabel.text = localizedString("bl_notices_and_news").capitalizingFirstLetter()
		}
	}
	
    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet{
            subtitleLabel.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(NewsTableViewCell.tapSubtitle))
            subtitleLabel.addGestureRecognizer(tapGesture)
        }
    }
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
//        iconBackgroundView.layer.cornerRadius = iconBackgroundView.bounds.height / 2
//        iconBackgroundView.layer.masksToBounds = true
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
		self.backgroundColor = DetailCardCellAndViewThemeColor.iconBackgrounds.value
		selectionStyle = .none
    }
	
	func configure(with subtitleAttrString: NSAttributedString) {
		subtitleLabel.attributedText = subtitleAttrString
	}
    
    @objc func tapSubtitle(sender: UITapGestureRecognizer) {
        guard let attributedText = subtitleLabel.attributedText else {return}
        
        attributedText.enumerateAttribute(NSAttributedString.Key.link, in: NSMakeRange(0, attributedText.length), options: [.longestEffectiveRangeNotRequired]) { value, range, _ in
            if let urlString = value as? String {
                guard let url = URL(string: urlString) else {return}

                delegate?.openURL(url)
            }else if let url = value as? URL {
                delegate?.openURL(url)
            }
        }
            
    }

}
