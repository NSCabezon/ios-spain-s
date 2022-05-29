//
//  FractionatedPurchaseCarouselItemLoadingView.swift
//  Menu
//
//  Created by Ignacio González Miró on 7/7/21.
//

import UIKit
import UI
import CoreFoundationLib

final class FractionatedPurchaseCarouselLoadingView: XibView {
    @IBOutlet private weak var loadingImageView: UIImageView!
    @IBOutlet private weak var loadingLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func startAnimating() {
        loadingImageView.setPointsLoader()
    }
    
    func stopAnimating() {
        loadingImageView.removeLoader()
    }
}

private extension FractionatedPurchaseCarouselLoadingView {
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
        setSubtitleAppearance()
    }
    
    func setTitleAppearance() {
        let localizedConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 16), alignment: .center, lineBreakMode: .none)
        loadingLabel.configureText(withKey: "generic_popup_loadingContent", andConfiguration: localizedConfig)
        loadingLabel.textColor = .lisboaGray
        loadingLabel.numberOfLines = 1
    }
    
    func setSubtitleAppearance() {
        let localizedConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 12), alignment: .center, lineBreakMode: .none)
        subtitleLabel.configureText(withKey: "loading_label_moment", andConfiguration: localizedConfig)
        subtitleLabel.textColor = .grafite
        subtitleLabel.numberOfLines = 1
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityFractionatedPurchasesCarousel.carouselLoadingBaseView
        loadingImageView.accessibilityIdentifier = AccessibilityFractionatedPurchasesCarousel.carouselLoadingImageView
        loadingLabel.accessibilityIdentifier = AccessibilityFractionatedPurchasesCarousel.carouselLoadingTitleLabel
        subtitleLabel.accessibilityIdentifier = AccessibilityFractionatedPurchasesCarousel.carouselLoadingDescriptionLabel
    }
}
