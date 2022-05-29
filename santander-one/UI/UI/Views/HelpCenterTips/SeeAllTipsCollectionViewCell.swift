//
//  SeeAllTipsCollectionViewCell.swift
//  Account
//
//  Created by Juan Carlos López Robles on 8/10/20.
//
import CoreFoundationLib
import UIKit

final class SeeAllTipsCollectionViewCell: UICollectionViewCell {
    static let identifier = "SeeAllTipsCollectionViewCell"
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconImageView.image = Assets.image(named: "icnAdvicesWhite")
        self.descriptionLabel.text = localized("helpCenter_button_seeAllTips")
        self.viewContainer.layer.cornerRadius = 4
        self.accessibilityIdentifier = "helpCenterBtnSeeAllTips"
        self.descriptionLabel.accessibilityIdentifier = "helpCenter_button_seeAllTips"
        self.viewContainer.backgroundColor = .darkTorquoise
    }
}
