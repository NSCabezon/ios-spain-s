//
//  EcommerceLoadingContentView.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 8/3/21.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

public final class EcommerceLoadingContentView: XibView {
    @IBOutlet private weak var loadingImageView: UIImageView!
    @IBOutlet private weak var loadingLabel: UILabel!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension EcommerceLoadingContentView {
    func setupView() {
        self.backgroundColor = .clear
        self.loadingImageView.setPointsLoader()
        self.setLoadingText()
        self.setAccesibilityIds()
    }
    
    func setLoadingText() {
        let config = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14), alignment: .center, lineBreakMode: .byTruncatingTail)
        self.loadingLabel.configureText(withKey: "ecommerce_label_loadingPurchases", andConfiguration: config)
        self.loadingLabel.textColor = .lisboaGray
        self.loadingLabel.numberOfLines = 0
        self.loadingLabel.textAlignment = .center
    }
    
    func setAccesibilityIds() {
        self.accessibilityIdentifier = AccessibilityEcommerceLoadingView.baseView
        self.loadingLabel.accessibilityIdentifier = AccessibilityEcommerceLoadingView.loading
    }
}
