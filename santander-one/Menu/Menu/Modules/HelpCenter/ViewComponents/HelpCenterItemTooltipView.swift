//
//  HelpCenterItemTooltipView.swift
//  Menu
//
//  Created by Iván Estévez on 22/04/2020.
//

import UI
import CoreFoundationLib

struct HelpCenterItemTooltipViewConfiguration {
    let image: UIImage?
    let text: LocalizedStylableText
}

final class HelpCenterItemTooltipView: XibView {
    
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var itemLabel: UILabel!
    @IBOutlet private weak var itemImageView: UIImageView!

    convenience init(configuration: HelpCenterItemTooltipViewConfiguration, labelIdentifier: String? = nil, imageIdentifier: String? = nil) {
        self.init(frame: CGRect.zero)
        setupView(configuration: configuration)
        setAccessibilityIdentifiers(label: labelIdentifier, image: imageIdentifier)
    }
}

private extension HelpCenterItemTooltipView {
    func setupView(configuration: HelpCenterItemTooltipViewConfiguration) {
        separatorView.backgroundColor = UIColor.mediumSkyGray.withAlphaComponent(0.35)
        itemLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        itemLabel.textColor = .lisboaGray
        itemImageView.image = configuration.image
        itemLabel.configureText(withLocalizedString: configuration.text)
    }
    func setAccessibilityIdentifiers(label: String? = nil, image: String? = nil) {
        itemImageView.isAccessibilityElement = true
        setAccessibility { self.itemImageView.isAccessibilityElement = false }
        itemLabel.accessibilityIdentifier = label
        itemImageView.accessibilityIdentifier = image
    }
}

extension HelpCenterItemTooltipView: AccessibilityCapable { }
