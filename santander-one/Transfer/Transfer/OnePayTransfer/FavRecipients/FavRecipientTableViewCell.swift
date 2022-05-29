//
//  FavRicipientTableViewCell.swift
//  Transfer
//
//  Created by Ignacio González Miró on 27/05/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class FavRecipientTableViewCell: UITableViewCell {
    @IBOutlet weak private var baseView: UIView!
    @IBOutlet weak private var avatarView: UIView!
    @IBOutlet weak private var avatarName: UILabel!
    @IBOutlet weak private var favNameLabel: UILabel!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var accountLabel: UILabel!
    @IBOutlet weak private var bankImg: UIImageView!
    @IBOutlet weak private var separatorView: DottedLineView!
    @IBOutlet weak private var paperMoneyImg: UIImageView!
    @IBOutlet weak private var currencyLabel: UILabel!
    @IBOutlet weak private var worldImg: UIImageView!
    @IBOutlet weak private var countryLabel: UILabel!

    static let identifier = "FavRecipientTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    func config(with viewModel: ContactListItemViewModel) {
        self.avatarView.backgroundColor = viewModel.avatarColor
        if let iconUrl = viewModel.bankIconUrl {
            self.bankImg.loadImage(urlString: iconUrl)
        }
        self.avatarName.text = viewModel.avatarName
        self.favNameLabel.text = viewModel.name
        self.favNameLabel.isHidden = viewModel.name.isEmpty
        self.nameLabel.text = viewModel.beneficiaryName
        self.nameLabel.isHidden = viewModel.beneficiaryName.isEmpty
        self.accountLabel.text = viewModel.accountNumberPapel
        self.accountLabel.isHidden = viewModel.accountNumberPapel.isEmpty
        self.currencyLabel.text = viewModel.currency
        self.countryLabel.text = viewModel.countryCode
    }
    
    func setAccessibilityIdentifier(with idx: String) {
        self.avatarView.accessibilityIdentifier = AccessibilityFavRecipients.favUserAvatarLabel + idx
        self.favNameLabel.accessibilityIdentifier = AccessibilityFavRecipients.favUserAlias + idx
        self.nameLabel.accessibilityIdentifier = AccessibilityFavRecipients.favUserUsername + idx
        self.accountLabel.accessibilityIdentifier = AccessibilityFavRecipients.favUserIBAN + idx
        self.currencyLabel.accessibilityIdentifier = AccessibilityFavRecipients.favUserCurrency + idx
        self.countryLabel.accessibilityIdentifier = AccessibilityFavRecipients.favUserCountry + idx
    }
}

private extension FavRecipientTableViewCell {
    func setupUI() {
        self.setupLabels()
        self.setAppearance()
        self.setIdentifiers()
    }
    
    func setupLabels() {
        self.avatarName.font = UIFont.santander(type: .bold, size: 14.0)
        self.avatarName.textColor = .white
        self.favNameLabel.font = UIFont.santander(type: .bold, size: 16.0)
        self.favNameLabel.textColor = .lisboaGray
        self.nameLabel.font = UIFont.santander(size: 14.0)
        self.nameLabel.textColor = .lisboaGray
        self.accountLabel.font = UIFont.santander(size: 14.0)
        self.accountLabel.textColor = .lisboaGray
        self.currencyLabel.font = UIFont.santander(size: 14.0)
        self.currencyLabel.textColor = .lisboaGray
        self.countryLabel.font = UIFont.santander(size: 14.0)
        self.countryLabel.textColor = .lisboaGray
    }
    
    func setAppearance() {
        let cornerRadius = self.avatarView.layer.frame.width / 2
        self.avatarView.drawBorder(cornerRadius: cornerRadius, color: .white, width: 1.0)
        self.baseView.drawRoundedAndShadowedNew(radius: 5, borderColor: .lightSkyBlue, widthOffSet: 1, heightOffSet: 2)
        self.worldImg.image = Assets.image(named: "icnWorld")
        self.paperMoneyImg.image = Assets.image(named: "icnCurrency")
        self.separatorView.strokeColor = .mediumSkyGray
        self.backgroundColor = .clear
    }
    
    func setIdentifiers() {
        self.paperMoneyImg.accessibilityIdentifier = AccessibilityFavRecipients.icnCurrency
        self.worldImg.accessibilityIdentifier = AccessibilityFavRecipients.icnWorld
    }
}
