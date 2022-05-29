//
//  SegmentedItemWithImageAndText.swift
//  UI
//
//  Created by Ignacio González Miró on 14/10/2020.
//

import UIKit
import CoreFoundationLib

public final class SegmentedItemWithImageAndText: UIDesignableView {
    @IBOutlet private weak var cardImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override public func getBundleName() -> String {
        return "UI"
    }
    
    override public func commonInit() {
        super.commonInit()
        self.setAppeareance()
        self.setAccessibilityIds()
    }
    
    public func setupSegmentedItem(_ cardName: String, urlString: String) {
        self.titleLabel.text = cardName
        self.titleLabel.configureText(withKey: "", andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85))
        self.cardImage.loadImage(urlString: urlString, placeholder: Assets.image(named: "defaultCard"))
    }
    
    func setLabel(_ isSelected: Bool) {
         let fontType: FontType = isSelected ? .bold : .regular
         self.titleLabel.font = UIFont.santander(family: .text, type: fontType, size: 14.0)
     }
}

private extension SegmentedItemWithImageAndText {
    func setAppeareance() {
        self.backgroundColor = .clear
    }
    
    func setAccessibilityIds() {
        self.cardImage.accessibilityIdentifier = AccessibilitySegmentWithImageAndTitle.cardImage.rawValue
        self.titleLabel.accessibilityIdentifier = AccessibilitySegmentWithImageAndTitle.cardName.rawValue
    }
}
