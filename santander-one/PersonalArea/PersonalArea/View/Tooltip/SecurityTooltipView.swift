//
//  SecurityTooltipView.swift
//  PersonalArea
//
//  Created by Carlos Gutiérrez Casado on 22/04/2020.
//

import UIKit
import CoreFoundationLib
import UI

struct SecurityTooltipViewConfiguration {
    let image: UIImage?
    let text: LocalizedStylableText
    let imageAccessibilityId: String?
    let labelAccessibilityId: String?

    init(image: UIImage?, text: LocalizedStylableText) {
        self.init(image: image, text: text, imageAccessibilityId: nil, labelAccessibilityId: nil)
    }

    init(image: UIImage?, text: LocalizedStylableText, imageAccessibilityId: String?, labelAccessibilityId: String?) {
        self.image = image
        self.text = text
        self.imageAccessibilityId = imageAccessibilityId
        self.labelAccessibilityId = labelAccessibilityId
    }
}

class SecurityTooltipView: XibView {
    @IBOutlet weak var itemImageview: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    convenience init(configuration: SecurityTooltipViewConfiguration) {
        self.init(frame: CGRect.zero)
        setupView(configuration: configuration)
    }
}

private extension SecurityTooltipView {
    func setupView(configuration: SecurityTooltipViewConfiguration) {
        self.separatorView.backgroundColor = UIColor.mediumSkyGray.withAlphaComponent(0.35)
        self.itemLabel.textColor = .lisboaGray
        self.itemImageview.image = configuration.image
        self.itemLabel.configureText(withLocalizedString: configuration.text,
                                     andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14)))
        setupAccessibilityIdentifiers(from: configuration)
    }

    func setupAccessibilityIdentifiers(from configuration: SecurityTooltipViewConfiguration) {
        itemImageview.accessibilityIdentifier = configuration.imageAccessibilityId
        itemLabel.accessibilityIdentifier = configuration.labelAccessibilityId
    }
}
