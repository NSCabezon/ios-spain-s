//
//  ContactDetailItemView.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 29/04/2020.
//

import UIKit
import UI
import CoreFoundationLib

class EditFavouriteItemView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setViewModel(_ viewModel: EditFavouriteItemViewModel) {
        self.titleLabel.text = viewModel.title
        self.descriptionLabel.text = viewModel.description
        self.accessibilityIdentifier = viewModel.accesibilityIdentificator
    }
}

private extension EditFavouriteItemView {
    func setAppearance() {
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.font = .santander(family: .text, type: .light, size: 16.0)
        self.descriptionLabel.textColor = .lisboaGray
        self.descriptionLabel.font = .santander(family: .text, type: .bold, size: 16.0)
        self.separatorView.backgroundColor = .mediumSkyGray
    }
}
