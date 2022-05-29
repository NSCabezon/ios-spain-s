//
//  ContactDetailItemView.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 29/04/2020.
//

import CoreFoundationLib
import UIKit
import UI

class ContactDetailItemView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setViewModel(_ viewModel: ContactDetailItemViewModel) {
        self.titleLabel.configureText(withKey: viewModel.itemTitleKey)
        self.descriptionLabel.text = viewModel.itemValue
        self.accessibilityIdentifier = viewModel.accessibilityIdentifier
        self.titleLabel.accessibilityIdentifier = viewModel.itemTitleKey
        self.descriptionLabel.accessibilityIdentifier = viewModel.accessibilityIdentifierItemValue
    }
}

private extension ContactDetailItemView {
    func setAppearance() {
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.font = .santander(family: .text, type: .light, size: 16.0)
        self.descriptionLabel.textColor = .lisboaGray
        self.descriptionLabel.font = .santander(family: .text, type: .bold, size: 16.0)
        self.separatorView.backgroundColor = .mediumSkyGray
    }
}
