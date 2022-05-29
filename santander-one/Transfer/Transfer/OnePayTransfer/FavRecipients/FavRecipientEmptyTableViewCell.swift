//
//  FavRecipientEmptyTableViewCell.swift
//  Transfer
//
//  Created by Ignacio González Miró on 02/06/2020.
//

import UIKit
import UI
import CoreFoundationLib

class FavRecipientEmptyTableViewCell: UITableViewCell {
    @IBOutlet weak private var baseImg: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    
    static let identifier = "FavRecipientEmptyTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupLabels()
        self.setAppearance()
    }
    
    func config(_ countryName: String) {
        self.titleLabel.configureText(withKey: "onePay_title_emptyFavorites")
        self.descriptionLabel.text = localized("emptyFavoritesRecipients_label_notFavorite") + countryName
    }
}

private extension FavRecipientEmptyTableViewCell {
    func setupLabels() {
        self.titleLabel.font = UIFont.santander(size: 20.0)
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.textAlignment = .center
        self.descriptionLabel.font = UIFont.santander(family: .headline, type: .regular, size: 14.0)
        self.descriptionLabel.textColor = .lisboaGray
        self.descriptionLabel.textAlignment = .center
    }
    
    func setAppearance() {
        self.baseImg.image = Assets.image(named: "imgLeaves")
        self.backgroundColor = .clear
        self.selectionStyle = .none
    }
}
