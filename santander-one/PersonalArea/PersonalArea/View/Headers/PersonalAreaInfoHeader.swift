//
//  PersonalAreaInfoHeader.swift
//  PersonalArea
//
//  Created by alvola on 11/11/2019.
//

import UIKit
import UI
import CoreFoundationLib

protocol PersonalAreaInfoHeaderProtocol {
    func setImage(_ image: String, description: String)
}

final class PersonalAreaInfoHeader: DesignableView, PersonalAreaInfoHeaderProtocol {
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var iconImage: UIImageView?
    @IBOutlet weak var separationView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }
    
    func setImage(_ image: String, description: String) {
        self.descriptionLabel?.configureText(
            withKey: description,
            andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.90)
        )
        self.iconImage?.image = Assets.image(named: image)?.withRenderingMode(.alwaysTemplate)
        self.iconImage?.tintColor = .botonRedLight
        self.setAccessibilityIdentifiers(image, description: description)
    }
}

private extension PersonalAreaInfoHeader {
    func commonInit() {
        self.configureView()
        self.configureLabels()
    }
    
    func configureView() {
        self.contentView?.backgroundColor = UIColor.skyGray
        self.separationView?.backgroundColor = UIColor.mediumSkyGray
    }
    
    func configureLabels() {
        self.descriptionLabel?.font = UIFont.santander(family: .text, type: .light, size: 14.0)
        self.descriptionLabel?.textColor = UIColor.lisboaGray
    }
    
    func setAccessibilityIdentifiers(_ image: String, description: String) {
        self.descriptionLabel?.accessibilityIdentifier = description
        self.iconImage?.accessibilityIdentifier = image
    }
}
