//
//  FavouriteContactCell.swift
//  GlobalPosition
//
//  Created by Ignacio González Miró on 22/09/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class FavouriteContactCell: UICollectionViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var avatarView: UIView!
    @IBOutlet private weak var titleAvatar: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var ibanLabel: UILabel!
    @IBOutlet private weak var bankImage: UIImageView!

    static let identifier: String = "FavouriteContactCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.avatarView.layer.cornerRadius = self.avatarView.bounds.height / 2
    }

    func configCell(_ viewModel: FavouriteContactViewModel) {
        self.titleAvatar.text = viewModel.avatarName
        self.setParagraphStyle(to: self.titleLabel, text: viewModel.name)
        self.ibanLabel.text = viewModel.accountNumber
        self.avatarView.backgroundColor = viewModel.avatarColor
        if let bankIconUrl = viewModel.bankIconUrl {
            self.bankImage.loadImage(urlString: bankIconUrl)
        } else {
            self.bankImage.image = nil
        }
        self.updateAccessibilityValue()
    }
    
    func configureShadow() {
        self.drawShadow(offset: 2, opaticity: 1, color: UIColor.lightSanGray, radius: 1)
        self.layer.masksToBounds = false
    }
}

private extension FavouriteContactCell {
    func setupView() {
        self.setupContainerView()
        self.setupLabels()
        self.setAccessibilityId()
        self.setAccessibilityLabel()
        self.disableAccessibilityElements()
    }
    
    func setupLabels() {
        self.titleAvatar.setSantanderTextFont(type: .bold, size: 15, color: .white)
        self.ibanLabel.setSantanderTextFont(size: 14, color: .lisboaGray)
    }
    
    func setupContainerView() {
        self.containerView.drawShadow(offset: 1, opaticity: 0.59, color: UIColor.black.withAlphaComponent(0.05), radius: 1)
        self.containerView.layer.masksToBounds = false
        self.containerView.clipsToBounds = false
        self.containerView.drawBorder(cornerRadius: 5, color: UIColor.lightSkyBlue, width: 1)
    }
    
    func setParagraphStyle(to label: UILabel, text: String) {
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
    
    func setAccessibilityId() {
        self.containerView.accessibilityIdentifier = AccessibilityPGFavouriteCarousel.favouritePill.rawValue
    }
    
    func setAccessibilityLabel() {
        self.accessibilityLabel = localized("voiceover_favorite")
        self.updateAccessibilityValue()
        self.accessibilityTraits = .button
        self.isAccessibilityElement = true
    }
    
    func updateAccessibilityValue() {
        let titleValue = self.titleLabel.text ?? ""
        let ibanValue = self.ibanLabel.text ?? ""
        self.accessibilityValue = titleValue + "\n" +
            ibanValue
    }
    
    func disableAccessibilityElements() {
        self.titleAvatar.isAccessibilityElement = false
        self.titleLabel.isAccessibilityElement = false
        self.ibanLabel.isAccessibilityElement = false
    }
}
