//
//  OneFavoriteContactCardCollectionViewCell.swift
//  TransferOperatives
//
//  Created by Francisco del Real Escudero on 2/12/21.
//

import UIOneComponents
import CoreFoundationLib
import UIKit
import UI

public class OneFavoriteContactCardCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var oneFavoriteContactCardView: OneFavoriteContactCardView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        layer.shadowOffset = CGSize(width: 1,
                                    height: 2)
        layer.shadowOpacity = 0.35
        layer.shadowColor = UIColor.oneLisboaGray.cgColor
        layer.shadowRadius = 4
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        layer.masksToBounds = false
    }
    
    public func set(model: OneFavoriteContactCardViewModel) {
        self.oneFavoriteContactCardView.setupFavoriteContactViewModel(model)
    }
    
    public func set(delegate: OneFavoriteContactCardDelegate) {
        self.oneFavoriteContactCardView.delegate = delegate
    }
}
