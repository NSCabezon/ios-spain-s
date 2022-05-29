//
//  ContactDetailHeaderView.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 29/04/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class ContactDetailHeaderView: XibView {
    @IBOutlet private weak var avatarView: UIView!
    @IBOutlet private weak var avatarNameLabel: UILabel!
    @IBOutlet private weak var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setViewModel(_ viewModel: ContactDetailViewModel) {
        self.avatarNameLabel.text = viewModel.avatarName
        self.avatarView.backgroundColor = viewModel.avatarColor
    }
}

private extension ContactDetailHeaderView {
    func setAppearance() {
        self.avatarView.layer.cornerRadius = self.avatarView.bounds.height / 2
        self.contentView?.backgroundColor = .skyGray
        self.avatarNameLabel.textColor = .white
        self.avatarNameLabel.font = .santander(family: .text, type: .bold, size: 34.0)
        self.avatarNameLabel.adjustsFontSizeToFitWidth = true
        self.avatarNameLabel.minimumScaleFactor = 0.5
        self.avatarNameLabel.baselineAdjustment = .alignCenters
        self.setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        self.contentView.accessibilityIdentifier = AccessibilityContactDetail.viewHeader
        self.avatarView.accessibilityIdentifier = AccessibilityContactDetail.headerAvatarCircleView
        self.avatarNameLabel.accessibilityIdentifier = AccessibilityContactDetail.headerLabelAvatarName
    }
}
