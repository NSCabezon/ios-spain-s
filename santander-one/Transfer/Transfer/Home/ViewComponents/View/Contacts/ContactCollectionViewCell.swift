//
//  ContactCollectionViewCell.swift
//  Transfer
//
//  Created by José Carlos Estela Anguita on 05/02/2020.
//

import UIKit
import CoreFoundationLib

final class ContactCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var avatarContainerView: UIView!
    @IBOutlet private weak var nameAvatarLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var accountNumberLabel: UILabel!
    @IBOutlet private weak var bankImage: UIImageView!
    private var groupedAccessibilityElements: [Any]?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.avatarContainerView.layer.cornerRadius = self.avatarContainerView.bounds.height / 2
    }
    
    func setup(with viewModel: ContactViewModel) {
        self.nameAvatarLabel.text = viewModel.avatarName
        self.setParagraphStyle(to: self.nameLabel, text: viewModel.name)
        self.accountNumberLabel.text = viewModel.accountNumber
        self.avatarContainerView.backgroundColor = viewModel.avatarColor
        if let bankIconUrl = viewModel.bankIconUrl {
            self.bankImage.loadImage(urlString: bankIconUrl)
        }
        self.setAccessibility()
        self.setupAccessibilityId()
    }
    
    private func setupView() {
        self.setupContainerView()
        self.setupLabels()
    }
    
    private func setupLabels() {
        self.nameAvatarLabel.setSantanderTextFont(type: .bold, size: 15, color: .white)
        self.accountNumberLabel.setSantanderTextFont(size: 14, color: .lisboaGray)
    }
    
    private func setupContainerView() {
        self.containerView.backgroundColor = UIColor.white
        self.containerView.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.containerView.layer.shadowOpacity = 0.59
        self.containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        self.containerView.layer.shadowRadius = 0.0
        self.containerView.layer.masksToBounds = false
        self.containerView.clipsToBounds = false
        self.containerView.drawBorder(cornerRadius: 5, color: UIColor.lightSkyBlue, width: 1)
    }
    
    private func setParagraphStyle(to label: UILabel, text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineHeightMultiple = 0.75
        let builder = TextStylizer.Builder(fullText: text)
        label.attributedText = builder
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: text)
                .setStyle(UIFont.santander(family: .text, type: .bold, size: 14))
                .setColor(.lisboaGray)
                .setParagraphStyle(paragraphStyle)
        )
            .build()
    }
    
    private func setAccessibility() {
        self.nameLabel.accessibilityTraits = .button
        self.nameAvatarLabel.accessibilityElementsHidden = true
        self.accountNumberLabel.accessibilityElementsHidden = true
    }
    
    private func setupAccessibilityId() {
        self.containerView.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeButtonFavorite
        self.nameAvatarLabel.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeLabelFavoriteInitials
        self.nameLabel.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeLabelFavoriteName
        self.accountNumberLabel.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeLabelFavoriteAccountNumber
        self.bankImage.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeViewFavoriteBankIcon
        self.avatarContainerView.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeViewFavoriteInitialsCircle
    }
}

extension ContactCollectionViewCell {
    public override var accessibilityElements: [Any]? {
        get {
            if let groupedAccessibilityElements = groupedAccessibilityElements {
                return groupedAccessibilityElements
            }
            let elements = self.groupElements([nameAvatarLabel,
                                               nameLabel,
                                               accountNumberLabel])
            groupedAccessibilityElements = elements
            return groupedAccessibilityElements
        }
        set {
            groupedAccessibilityElements = newValue
        }
    }
}
