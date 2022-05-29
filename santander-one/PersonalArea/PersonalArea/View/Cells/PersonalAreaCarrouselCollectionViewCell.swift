//
//  PersonalAreaCarrouselCollectionViewCell.swift
//  PersonalArea
//
//  Created by alvola on 10/12/2019.
//

import UIKit
import UI
import CoreFoundationLib

class PersonalAreaCarrouselCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var frameView: UIView?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var iconImage: UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    func setDesc(_ desc: String) {
        descriptionLabel?.text = localized(desc)
        descriptionLabel?.accessibilityIdentifier = desc
        iconImage?.accessibilityIdentifier = desc + "_icon"
    }
    
    private func commonInit() {
        configureLabel()
        configureView()
        iconImage?.image = Assets.image(named: "icnMobileChat")
    }
    
    private func configureView() {
        clipsToBounds = false
        frameView?.layer.borderColor = UIColor.mediumSkyGray.cgColor
        frameView?.layer.borderWidth = 1.0
        frameView?.layer.cornerRadius = 6.0
        
        frameView?.layer.shadowColor = UIColor.lightSanGray.cgColor
        frameView?.layer.shadowRadius = 3
        frameView?.layer.shadowOffset = CGSize(width: 0, height: 3)
        frameView?.layer.shadowOpacity = 0.7
    }
    
    private func configureLabel() {
        descriptionLabel?.font = UIFont.santander(family: .text, size: 16.0)
        descriptionLabel?.textColor = UIColor.lisboaGray
    }
}
