//
//  BizumSummaryOrganizationView.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 11/02/2021.
//

import Foundation
import UI
import CoreFoundationLib

final class BizumSummaryOrganizationView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var organizationImageView: UIImageView!
    @IBOutlet weak var organizationNameLabel: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var initialsLabel: UILabel!
    
    private var viewModel: BizumSummaryOrganizationViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupViewModel(_ viewModel: BizumSummaryOrganizationViewModel) {
        self.viewModel = viewModel
        self.titleLabel.text = localized("confirmation_label_destination")
        self.organizationNameLabel.text = viewModel.name
        self.setIcon()
    }
}

private extension BizumSummaryOrganizationView {
    func setupView() {
        self.titleLabel.setSantanderTextFont(type: .regular, size: 13, color: .grafite)
        self.organizationNameLabel.setSantanderTextFont(type: .bold, size: 14, color: .lisboaGray)
        self.organizationNameLabel.numberOfLines = 2
        self.organizationNameLabel.lineBreakMode = .byTruncatingTail
        self.setNameView()
        self.setAccessibilityIdentifiers()
    }
    
    func setNameView() {
        let cornerRadius = self.nameView.layer.frame.width / 2
        self.nameView.drawBorder(cornerRadius: cornerRadius, color: .white, width: 1.0)
        self.nameView.isHidden = true
        self.initialsLabel.setSantanderTextFont(type: .bold, size: 15, color: .white)
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityBizumSummary.organizationTitle
        self.organizationImageView.accessibilityIdentifier = AccessibilityBizumSummary.organizationImage
        self.organizationNameLabel.accessibilityIdentifier = AccessibilityBizumSummary.organizationName
    }
    
    func setIcon() {
        self.organizationImageView.image = nil
        self.organizationImageView.clipsToBounds = true
        self.organizationImageView.contentMode = .scaleAspectFit
        guard let viewModel = self.viewModel,
              let iconUrl = viewModel.iconUrl else {
            self.setInitialsAvatar()
            return
        }
        self.organizationImageView.loadImage(urlString: iconUrl) { [weak self] in
            guard self?.organizationImageView.image == nil else { return }
            self?.setInitialsAvatar()
        }
    }
    
    func setInitialsAvatar() {
        guard let viewModel = self.viewModel else { return }
        self.initialsLabel.text = viewModel.avatarName
        self.nameView.backgroundColor = viewModel.avatarColor
        self.organizationImageView.isHidden = true
        self.nameView.isHidden = false
    }
}
