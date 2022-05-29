//
//  EcommerceFooterSecurityView.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 3/3/21.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

public final class EcommerceFooterSecurityView: XibView {
    @IBOutlet private weak var sanKeyImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension EcommerceFooterSecurityView {
    func setupView() {
        self.backgroundColor = .clear
        self.sanKeyImageView.image = Assets.image(named: "icnSecurePurchase")
        self.setTitle()
        self.setAccessibilityIds()
    }
    
    func setTitle() {
        let font = UIFont.santander(family: .text, type: .regular, size: 14)
        let localizedConfiguration = LocalizedStylableTextConfiguration(font: font, alignment: .left, lineHeightMultiple: 0.8, lineBreakMode: .byTruncatingTail)
        self.titleLabel.configureText(withKey: "ecommerce_label_safeOperation", andConfiguration: localizedConfiguration)
        self.titleLabel.numberOfLines = 1
        self.titleLabel.textColor = .brownGray
    }
    
    func setAccessibilityIds() {
        self.sanKeyImageView.accessibilityIdentifier = AccessibilityEcommerceFooterView.sanSafeImage
        self.titleLabel.accessibilityIdentifier = AccessibilityEcommerceFooterView.sanSafeLabel
    }
}
