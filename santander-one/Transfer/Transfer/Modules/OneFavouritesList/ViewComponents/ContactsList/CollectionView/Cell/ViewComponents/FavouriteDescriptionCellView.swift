//
//  FavouriteDescriptionCellView.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 7/1/22.
//

import CoreFoundationLib
import UIOneComponents
import UIKit
import UI

final class FavouriteDescriptionCellView: XibView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var aliasLabel: UILabel!
    @IBOutlet private weak var holderLabel: UILabel!
    @IBOutlet private weak var ibanLabel: UILabel!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var logoImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logoImageWidthConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setContact(_ contact: FavouriteContact) {
        aliasLabel.text = contact.alias
        holderLabel.text = contact.holder
        ibanLabel.text = contact.accountNumber
        setBankImage(bankIconUrl: contact.bankIconUrl)
    }
}

private extension FavouriteDescriptionCellView {
    func setAppearance() {
        setLabel(aliasLabel, fontName: .oneB400Bold)
        setLabel(holderLabel, fontName: .oneB300Regular)
        setLabel(ibanLabel, fontName: .oneB200Regular)
        setAccessibilityIdentifiers()
    }
    
    func setLabel(_ label: UILabel, fontName: FontName) {
        label.font = .typography(fontName: fontName)
        label.textColor = .oneLisboaGray
    }
    
    func setBankImage(bankIconUrl: String?) {
        if let iconUrl = bankIconUrl {
            logoImageView.loadImage(urlString: iconUrl) { [weak self] in
                if let iconUrlSize = self?.logoImageView?.image?.size {
                    let height = self?.logoImageHeightConstraint.constant
                    let newWidth = (iconUrlSize.width * (height ?? 15)) / iconUrlSize.height
                    self?.logoImageWidthConstraint.constant = newWidth
                } else {
                    self?.logoImageView.image = nil
                    self?.logoImageWidthConstraint.constant = 0
                }
            }
        } else {
            logoImageView.image = nil
            logoImageWidthConstraint.constant = 0
        }
    }
    
    func setAccessibilityIdentifiers() {
        aliasLabel.accessibilityIdentifier = AccessibilityOneFavouritesList.favouriteContactLabelAlias
        holderLabel.accessibilityIdentifier = AccessibilityOneFavouritesList.favouriteContactLabelHolder
        ibanLabel.accessibilityIdentifier = AccessibilityOneFavouritesList.favouriteContactLabelIban
        logoImageView.accessibilityIdentifier = AccessibilityOneFavouritesList.favouriteContactImageBankLogo
    }
}
