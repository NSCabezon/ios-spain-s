//
//  ComingFeatureDescriptionView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 21/02/2020.
//

import Foundation
import CoreFoundationLib
import UI

class ComingFeatureDescriptionView: XibView {
    @IBOutlet weak var timeRemainingView: UIView!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    private func configureTimeRemaining() {
        self.timeRemainingView.backgroundColor = .darkTorquoise
        self.timeRemainingView.drawBorder(cornerRadius: 2, color: .darkTorquoise, width: 1)
        self.timeRemainingLabel.font = .santander(family: .text, type: .bold, size: 10)
        self.timeRemainingLabel.textColor = .white
    }
    
    private func configureStackViewLabels() {
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 20)
        self.titleLabel.textColor = .lisboaGray
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.textColor = .mediumSanGray
        self.ownerLabel.textColor = .lisboaGray
    }
    
    private func configureView() {
        self.configureTimeRemaining()
        self.configureStackViewLabels()
        self.setAccessibilityIdentifiers()
    }
    
    private func setAccessibilityIdentifiers() {
        self.timeRemainingView.accessibilityIdentifier = "timeRemainingView"
        self.titleLabel.accessibilityIdentifier = "titleLabel"
        self.descriptionLabel.accessibilityIdentifier = "descriptionLabel"
        self.ownerLabel.accessibilityIdentifier = "ownerLabel"
        self.iconImageView.accessibilityIdentifier = "iconImageView"
    }
    
    public func setViewModel(_ viewModel: ComingFeatureDescriptionViewModel) {
        if let imageUrl = viewModel.logoURL {
            self.iconImageView.loadImage(urlString: imageUrl)
        } else {
            self.iconImageView.image = Assets.image(named: "icnIdea")
        }
        if viewModel.date?.isEmpty ?? false {
            self.timeRemainingView.isHidden = true
        } else {
            self.timeRemainingLabel.text = viewModel.date
            self.timeRemainingView.isHidden = false
        }
        self.titleLabel.text = viewModel.title
        self.descriptionLabel.configureText(withKey: viewModel.description,
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16),
                                                                                                 lineBreakMode: .byWordWrapping))
        self.ownerLabel.attributedText = viewModel.owner
    }
}
