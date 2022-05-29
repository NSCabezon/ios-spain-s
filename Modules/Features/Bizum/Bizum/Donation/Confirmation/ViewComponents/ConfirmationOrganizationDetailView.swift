//
//  ConfirmationOrganizationDetailView.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 22/02/2021.
//

import Foundation
import UI
import CoreFoundationLib

final class ConfirmationOrganizationDetailView: XibView {
    @IBOutlet weak private var avatarContainerView: UIView!
    @IBOutlet weak private var avatarLabel: UILabel!
    @IBOutlet weak private var thumbnailImageView: UIImageView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var sendLabel: UILabel!
    private var viewModel: ConfirmationOrganizationDetailViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setView(_ viewModel: ConfirmationOrganizationDetailViewModel) {
        self.viewModel = viewModel
        self.nameLabel.text = viewModel.name
        self.setIcon()
    }
}

private extension ConfirmationOrganizationDetailView {
    func setupView() {
        self.setAvatarView()
        self.setLabels()
    }
    
    func setAvatarView() {
        let cornerRadius = self.avatarContainerView.layer.frame.width / 2
        self.avatarContainerView.drawBorder(cornerRadius: cornerRadius, color: .white, width: 1.0)
        self.avatarLabel.setSantanderTextFont(type: .bold, size: 15.0, color: .white)
        self.thumbnailImageView.layer.cornerRadius = cornerRadius
        self.avatarLabel.isHidden = true
    }
    
    func setLabels() {
        self.nameLabel.setSantanderTextFont(type: .bold, size: 14, color: .lisboaGray)
        self.nameLabel.numberOfLines = 2
        self.nameLabel.lineBreakMode = .byTruncatingTail
        self.sendLabel.setSantanderTextFont(type: .regular, size: 12, color: .grafite)
        self.sendLabel.text = localized("confirmation_label_send")
    }
    
    func setIcon() {
        self.thumbnailImageView.image = nil
        self.thumbnailImageView.clipsToBounds = true
        self.thumbnailImageView.contentMode = .scaleAspectFit
        guard let viewModel = self.viewModel,
              let iconUrl = viewModel.iconUrl else {
            self.setInitialsAvatar()
            return
        }
        self.thumbnailImageView.loadImage(urlString: iconUrl) { [weak self] in
            guard self?.thumbnailImageView.image == nil else { return }
            self?.setInitialsAvatar()
        }
    }
    
    func setInitialsAvatar() {
        guard let viewModel = self.viewModel else { return }
        self.avatarLabel.text = viewModel.avatarName
        self.avatarContainerView.backgroundColor = viewModel.avatarColor
        self.thumbnailImageView.isHidden = true
        self.avatarLabel.isHidden = false
    }
}
