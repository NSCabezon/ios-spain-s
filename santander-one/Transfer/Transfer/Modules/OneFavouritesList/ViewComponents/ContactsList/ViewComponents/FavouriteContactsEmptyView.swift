//
//  FavouriteContactsEmptyView.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 24/1/22.
//

import CoreFoundationLib
import UIOneComponents
import UIKit
import UI

final class FavouriteContactsEmptyView: XibView {
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setView(_ item: FavouriteContactsEmptyItem) {
        titleLabel.text = localized(item.titleKey)
        descriptionLabel.text = localized(item.descriptionKey)
        setAccessibilityIdentifiers(titleKey: item.titleKey,
                                    descriptionKey: item.descriptionKey)
    }
}

private extension FavouriteContactsEmptyView {
    func setupView() {
        setImageView()
        setLabel(titleLabel, fontName: .oneH100Bold)
        setLabel(descriptionLabel, fontName: .oneB400Regular)
        setAccessibilityInfo()
    }
    
    func setImageView() {
        backgroundImageView.setLeavesLoader()
    }
    
    func setLabel(_ label: UILabel, fontName: FontName) {
        label.font = .typography(fontName: fontName)
        label.textColor = .oneLisboaGray
    }
    
    func setAccessibilityInfo() {
        setAccessibility {
            self.backgroundImageView?.isAccessibilityElement = true
            self.titleLabel.isAccessibilityElement = false
            self.descriptionLabel.isAccessibilityElement = false
            self.backgroundImageView?.accessibilityLabel = "\(self.titleLabel.text ?? ""). \(self.descriptionLabel.text ?? "")"
        }
    }
    
    func setAccessibilityIdentifiers(titleKey: String, descriptionKey: String) {
        backgroundImageView.accessibilityIdentifier = AccessibilityOneFavouritesList.favouriteContactEmptyImageView
        titleLabel.accessibilityIdentifier = titleKey
        descriptionLabel.accessibilityIdentifier = descriptionKey
    }
}

extension FavouriteContactsEmptyView: AccessibilityCapable {}
