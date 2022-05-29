//
//  PreconceivedBannerDetailView.swift
//  Menu
//
//  Created by Ignacio González Miró on 21/12/21.
//

import UIKit
import UI
import CoreFoundationLib

final class PreconceivedBannerDetailView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension PreconceivedBannerDetailView {
    func setupView() {
        backgroundColor = .clear
        setTitleLabel()
        arrowImageView.image = Assets.image(named: "icnArrowRightGreen14pt")
        arrowImageView.contentMode = .scaleAspectFill
        setAccessibilityIds()
    }
    
    func setTitleLabel() {
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .micro, type: .regular, size: 12),
            alignment: .left,
            lineBreakMode: .none
        )
        titleLabel.configureText(
            withKey: "financing_button_preLoadInterested",
            andConfiguration: localizedConfig
        )
        titleLabel.textColor = .darkTorquoise
        titleLabel.numberOfLines = 1
    }
    
    func setAccessibilityIds() {
        titleLabel.accessibilityIdentifier = AccessibilityPreconceivedBannerView.titleLabel
        arrowImageView.accessibilityIdentifier = AccessibilityPreconceivedBannerView.arrowImageView
    }
}
