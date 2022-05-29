//
//  FractionatedPurchasesSeeMoreCollectionViewCell.swift
//  Menu
//
//  Created by Ignacio González Miró on 9/7/21.
//

import UIKit
import UI
import CoreFoundationLib

final class FractionatedPurchasesSeeMoreCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var baseView: UIView!
    @IBOutlet private weak var titleImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    static let loadMoreIdentifier = "FractionatedPurchasesSeeMoreCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        baseView.roundCorners(corners: [.allCorners], radius: 5)
    }
}

private extension FractionatedPurchasesSeeMoreCollectionViewCell {
    func setupView() {
        backgroundColor = .clear
        setBaseView()
        titleImageView.image = Assets.image(named: "icnFractionablePurchases2")
        setTitleLabel()
        setAccessibilityIds()
    }
    
    func setBaseView() {
        baseView.backgroundColor = .darkTorquoise
        baseView.roundCorners(corners: [.allCorners], radius: 5)
    }
    
    func setTitleLabel() {
        let titleConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 15), alignment: .center, lineHeightMultiple: 0.75, lineBreakMode: .none)
        titleLabel.configureText(withKey: "fractionatePurchases_label_seeMore", andConfiguration: titleConfiguration)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
    }
    
    func setAccessibilityIds() {
        baseView.accessibilityIdentifier = AccessibilityFractionatedPurchasesCarouselItem.seeMoreCellBaseView
        titleImageView.accessibilityIdentifier = AccessibilityFractionatedPurchasesCarouselItem.seeMoreCellImageView
        titleLabel.accessibilityIdentifier = AccessibilityFractionatedPurchasesCarouselItem.seeMoreCellTitleLabel
    }
}
