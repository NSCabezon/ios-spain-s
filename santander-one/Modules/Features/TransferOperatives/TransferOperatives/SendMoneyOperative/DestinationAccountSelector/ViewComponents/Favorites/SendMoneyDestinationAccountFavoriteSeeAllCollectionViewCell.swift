//
//  SendMoneyDestinationAccountFavoriteSeeAllCollectionViewCell.swift
//  Pods
//
//  Created by Angel Abad Perez on 28/9/21.
//

import UIOneComponents
import CoreFoundationLib

final class SendMoneyDestinationAccountFavoriteSeeAllCollectionViewCell: UICollectionViewCell {
    private enum Constants {
        static let icon: String = "icnStar"
        static let description: String = "sendMoney_button_seeAllFavorites"
    }
    
    @IBOutlet private weak var seeAllCard: OneSeeAllCardView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }

    public func setAccessibilitySuffix(_ suffix: String) {
        self.seeAllCard.setAccessibilitySuffix(suffix)
    }
}

private extension SendMoneyDestinationAccountFavoriteSeeAllCollectionViewCell {
    func setupView() {
        self.clipsToBounds = false
        self.contentView.isUserInteractionEnabled = false
        self.configureSeeAllCard()
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    func configureSeeAllCard() {
        self.seeAllCard.setViewModel(
            OneSeeAllCardViewModel(imageKey: Constants.icon,
                                   descriptionKey: Constants.description)
        )
    }
    
    func setAccessibilityInfo() {
        self.accessibilityLabel = localized("sendMoney_button_seeAllFavorites")
        self.isAccessibilityElement = true
        self.accessibilityTraits = .button
    }
}

extension SendMoneyDestinationAccountFavoriteSeeAllCollectionViewCell: AccessibilityCapable {}
