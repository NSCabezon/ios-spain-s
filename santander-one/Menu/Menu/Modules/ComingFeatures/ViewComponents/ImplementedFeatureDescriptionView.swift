//
//  ImplementedFeatureDescriptionView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 26/02/2020.
//

import Foundation
import UI
import CoreFoundationLib

class ImplementedFeatureDescriptionView: XibView {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.configureView()
        self.setAccessibilityIdentifiers()
    }
    
    private func configureView() {
        self.dateLabel.font = .santander(family: .text, type: .regular, size: 14)
        self.dateLabel.textColor = .mediumSanGray
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 20)
        self.titleLabel.textColor = .lisboaGray
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.descriptionLabel.textColor = .mediumSanGray
        self.ownerLabel.textColor = .lisboaGray
    }
    
    private func setAccessibilityIdentifiers() {
        self.dateLabel.accessibilityIdentifier = "dateLabel"
        self.titleLabel.accessibilityIdentifier = "titleLabel"
        self.descriptionLabel.accessibilityIdentifier = "descriptionLabel"
        self.ownerLabel.accessibilityIdentifier = "ownerLabel"
        self.iconImageView.accessibilityIdentifier = "iconImageView"
    }
    
    func setViewModel(_ viewModel: ImplementedFeatureDescriptionViewModel) {
        if let imageUrl = viewModel.logoURL {
            self.iconImageView.loadImage(urlString: imageUrl)
        } else {
            self.iconImageView.image = Assets.image(named: "icnIdea")
        }
        self.dateLabel.text = viewModel.date
        self.titleLabel.text = viewModel.title
        self.descriptionLabel.configureText(withKey: viewModel.description)
        self.ownerLabel.attributedText = viewModel.owner
    }
}
