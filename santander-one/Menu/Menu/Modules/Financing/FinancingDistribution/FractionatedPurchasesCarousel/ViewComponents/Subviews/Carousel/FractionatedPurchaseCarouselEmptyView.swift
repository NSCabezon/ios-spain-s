//
//  FractionatedPurchaseCarouselItemEmptyView.swift
//  Menu
//
//  Created by Ignacio González Miró on 7/7/21.
//

import UIKit
import UI
import CoreFoundationLib

final class FractionatedPurchaseCarouselEmptyView: XibView {
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension FractionatedPurchaseCarouselEmptyView {
    func setupView() {
        backgroundColor = .clear
        frame = bounds
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setAppearance()
        setAccessibilityIds()
    }
    
    func setAppearance() {
        setTitleAppearance()
        backgroundImageView.image = Assets.image(named: "imgLeaves")
    }
    
    func setTitleAppearance() {
        let localizedKey = "fractionatePurchases_text_emptyView"
        let localizedFont: UIFont = .santander(size: 22)
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: localizedFont,
            alignment: .center,
            lineBreakMode: .none
        )
        titleLabel.configureText(withKey: localizedKey, andConfiguration: localizedConfig)
        titleLabel.textColor = .lisboaGray
        titleLabel.numberOfLines = 0
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityFractionatedPurchasesCarousel.carouselEmptyBaseView
        backgroundImageView.accessibilityIdentifier = AccessibilityFractionatedPurchasesCarousel.carouselEmptyImageView
        titleLabel.accessibilityIdentifier = AccessibilityFractionatedPurchasesCarousel.carouselEmptyTitleLabel
    }
}
