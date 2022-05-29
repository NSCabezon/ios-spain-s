//
//  LastBeneficiaryCollectionViewCell.swift
//  Transfer
//
//  Created by Ignacio González Miró on 22/05/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class LastBeneficiaryCollectionViewCell: UICollectionViewCell {
    static let identifier = "LastBeneficiaryCollectionViewCell"
    @IBOutlet weak private var avatarContainerView: UIView!
    @IBOutlet weak private var nameAvatarLabel: UILabel!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var ibanLabel: UILabel!
    @IBOutlet weak private var bankImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
        self.setAccessibilityIdentifiers()
    }
    
    func setup(with viewModel: EmittedSepaTransferViewModel) {
        let cornerRadius = self.avatarContainerView.layer.frame.width / 2
        self.avatarContainerView.drawBorder(cornerRadius: cornerRadius, color: .white, width: 1.0)
        self.nameAvatarLabel.text = viewModel.avatarName
        self.ibanLabel.text = viewModel.accountIban
        self.titleLabel.configureText(withKey: viewModel.name,
                                      andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.8))
        self.avatarContainerView.backgroundColor = viewModel.avatarColor
        self.bankImage.loadImage(urlString: viewModel.bankIconUrl)
        self.setupAccessibilityElements()
    }
}

private extension LastBeneficiaryCollectionViewCell {
    func setupView() {
        self.setupLabels()
        self.setAppearence()
    }
    
    func setupLabels() {
        self.nameAvatarLabel.setSantanderTextFont(type: .bold, size: 15, color: .white)
        self.ibanLabel.setSantanderTextFont(size: 14, color: .lisboaGray)
        self.titleLabel.setSantanderTextFont(type: .bold, size: 14, color: .lisboaGray)
        self.titleLabel.numberOfLines = 0
        self.titleLabel.adjustsFontSizeToFitWidth = false
        self.titleLabel.lineBreakMode = .byTruncatingTail
    }
    
    func setAppearence() {
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.layer.shadowOpacity = 0.59
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        self.layer.shadowRadius = 0.0
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.drawBorder(cornerRadius: 4, color: UIColor.lightSkyBlue, width: 1)
        self.ibanLabel.font = UIFont.santander(family: .text, type: .regular, size: 14.0)
        self.ibanLabel.textColor = .lisboaGray
    }
    
    func setAccessibilityIdentifiers() {
        self.nameAvatarLabel.accessibilityIdentifier = AccessibilityTransferDestination.lastBeneficiariesAvatar.rawValue
        self.titleLabel.accessibilityIdentifier = AccessibilityTransferDestination.lastBeneficiariesUsername.rawValue
        self.ibanLabel.accessibilityIdentifier = AccessibilityTransferDestination.lastBeneficiariesIBAN.rawValue
        self.bankImage.accessibilityIdentifier = AccessibilityTransferDestination.lastBeneficiariesBankIcon.rawValue
    }
}

private extension LastBeneficiaryCollectionViewCell {
    func setupAccessibilityElements() {
        self.contentView.subviews.forEach({$0.accessibilityElementsHidden = true})
        self.accessibilityLabel = self.nameAvatarLabel.appendSpeechFromElements([titleLabel,
                                                                                 ibanLabel])
    }
}
