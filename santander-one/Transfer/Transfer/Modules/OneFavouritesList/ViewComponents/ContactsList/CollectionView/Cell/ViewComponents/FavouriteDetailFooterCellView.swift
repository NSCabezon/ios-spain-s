//
//  FavouriteDetailFooterCellView.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 7/1/22.
//

import CoreFoundationLib
import UIOneComponents
import UIKit
import UI

final class FavouriteDetailFooterCellView: XibView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var separatorView: DottedLineView!
    @IBOutlet private weak var globalImageView: UIImageView!
    @IBOutlet private weak var countryCurrencyLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setDetailDescription(_ description: String?) {
        countryCurrencyLabel.text = description
    }
}

private extension FavouriteDetailFooterCellView {
    func setAppearance() {
        separatorView.pattern = .oneDesign
        globalImageView.image = Assets.image(named: "oneIcnGlobal")
        countryCurrencyLabel.font = .typography(fontName: .oneB300Regular)
        countryCurrencyLabel.textColor = .oneLisboaGray
        setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        globalImageView.accessibilityIdentifier = AccessibilityOneFavouritesList.favouriteContactImageGlobal
        countryCurrencyLabel.accessibilityIdentifier = AccessibilityOneFavouritesList.favouriteContactLabelCountryCurrency
    }
}
