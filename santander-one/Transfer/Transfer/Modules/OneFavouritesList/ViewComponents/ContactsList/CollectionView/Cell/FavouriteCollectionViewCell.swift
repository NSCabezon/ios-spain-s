//
//  FavouriteCollectionViewCell.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 7/1/22.
//

import CoreFoundationLib
import UIOneComponents
import UIKit
import UI

final class FavouriteCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: FavouriteCollectionViewCell.self)
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var oneAvatarView: OneAvatarView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var dragAndDropView: UIView!
    @IBOutlet private weak var dotsImageView: UIImageView!
    private var contact: FavouriteContact?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setAppearance()
        setAccessibilityIdentifiers()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
    
    func setContact(_ contact: FavouriteContact) {
        self.contact = contact
        oneAvatarView.setupAvatar(contact.oneAvatar)
        addFavouriteDescriptionView()
        addFavouriteFooterView()
    }
}

private extension FavouriteCollectionViewCell {
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityOneFavouritesList.favouriteContactCell
        dragAndDropView.accessibilityIdentifier = AccessibilityOneFavouritesList.favouriteContactBtnMoveControl
        dotsImageView.accessibilityIdentifier = AccessibilityOneFavouritesList.favouriteContactOneIcnDots
    }
    
    func setAppearance() {
        setDragAndDropView()
        setContainerView()
    }
    
    func setDragAndDropView() {
        dragAndDropView.backgroundColor = .oneSkyGray
        dragAndDropView.roundCorners(corners: [.topRight, .bottomRight], radius: 8)
        dotsImageView.image = Assets.image(named: "oneIcnDots")
        separatorView.backgroundColor = .oneMediumSkyGray
    }
    
    func setContainerView() {
        layer.shadowOffset = CGSize(width: 1,
                                    height: 2)
        layer.shadowOpacity = 0.35
        layer.shadowColor = UIColor.oneLightSanGray.cgColor
        layer.shadowRadius = 4
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        layer.masksToBounds = false
        containerView.setOneCornerRadius(type: .oneShRadius8)
    }
    
    func addFavouriteDescriptionView() {
        guard let contact = self.contact else { return }
        let view = FavouriteDescriptionCellView()
        view.setContact(contact)
        stackView.addArrangedSubview(view)
    }
    
    func addFavouriteFooterView() {
        guard let contact = self.contact else { return }
        let view = FavouriteDetailFooterCellView()
        view.setDetailDescription(contact.country)
        stackView.addArrangedSubview(view)
    }
    
    func resetCell() {
        contact = nil
        stackView.removeAllArrangedSubviews()
    }
}
