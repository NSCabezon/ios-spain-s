//
//  BizumSelectedNGOCollectionViewCell.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 15/02/2021.
//

import UIKit
import UI

class BizumSelectedNGOCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var logoContainerView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarInitialsLabel: UILabel!
    @IBOutlet weak var avatarView: UIView!
    static let identifier = "BizumSelectedNGOCollectionViewCell"
    private var viewModel: BizumNGOCollectionViewCellViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    func setViewModel(_ viewModel: BizumNGOCollectionViewCellViewModel) {
        self.viewModel = viewModel
        self.setNameLabel()
        self.setIcon()
    }
}

private extension BizumSelectedNGOCollectionViewCell {
    func setupView() {
        self.setViews()
        self.setAvatarView()
        self.setAccessibilityIdentifiers()
    }
    
    func setAvatarView() {
        let cornerRadius = self.avatarView.layer.frame.width / 2
        self.avatarView.drawBorder(cornerRadius: cornerRadius, color: .white, width: 1.0)
        self.avatarInitialsLabel.font = .santander(family: .text, type: .bold, size: 21)
        self.avatarInitialsLabel.textColor = .white
        self.avatarView.isHidden = true
    }
    
    func setNameLabel() {
        guard let viewModel = self.viewModel else { return }
        let textConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 14),
                                                                   lineHeightMultiple: 0.75)
        self.nameLabel.configureText(withKey: viewModel.name,
                                     andConfiguration: textConfiguration)
        self.nameLabel.textColor = .lisboaGray
    }
    
    func setViews() {
        self.containerView.backgroundColor = .clear
        self.logoContainerView.backgroundColor = .white
        self.footerView.backgroundColor = .lightSky
        self.separatorView.backgroundColor = .mediumSkyGray
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.setShadowAndBorder()
    }
    
    func setShadowAndBorder() {
        self.drawShadow(offset: (x: 1, y: 2),
                        opacity: 0.7,
                        color: UIColor.lightSkyBlue.withAlphaComponent(0.7),
                        radius: 0.5)
        self.contentView.subviews.first?.drawBorder(cornerRadius: 4,
                                                    color: UIColor.lightSkyBlue,
                                                    width: 1)
        self.logoContainerView.roundCorners(corners: [.topLeft, .topRight], radius: 4)
        self.footerView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 4)
    }
    
    func setIcon() {
        self.logoImageView.image = nil
        self.logoImageView.clipsToBounds = true
        self.logoImageView.contentMode = .scaleAspectFit
        guard let viewModel = self.viewModel,
              let iconUrl = viewModel.iconUrl else {
            self.setInitialsAvatar()
            return
        }
        self.logoImageView.loadImage(urlString: iconUrl) { [weak self] in
            guard self?.logoImageView.image == nil else { return }
            self?.setInitialsAvatar()
        }
    }
    
    func setInitialsAvatar() {
        guard let viewModel = self.viewModel else { return }
        self.avatarInitialsLabel.text = viewModel.avatarName
        self.avatarView.backgroundColor = viewModel.avatarColor
        self.logoImageView.isHidden = true
        self.avatarView.isHidden = false
    }
    
    func setAccessibilityIdentifiers() {
        self.nameLabel.accessibilityIdentifier = AccessibilityBizumDonation.ngoCellNameLabel
        self.logoImageView.accessibilityIdentifier = AccessibilityBizumDonation.ngoCellLogoImage
    }
}
