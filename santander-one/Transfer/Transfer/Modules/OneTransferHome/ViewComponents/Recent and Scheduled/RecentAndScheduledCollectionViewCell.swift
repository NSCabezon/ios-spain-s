//
//  RecentAndScheduledCollectionViewCell.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 14/12/21.
//

import UIOneComponents
import CoreFoundationLib
import UIKit
import UI

final public class RecentAndScheduledCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var onePastTransferCard: OnePastTransferCardView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        layer.shadowOffset = CGSize(width: 1, height: 2)
        layer.shadowOpacity = 0.15
        layer.shadowColor = UIColor.oneLisboaGray.cgColor
        layer.shadowRadius = 4
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        layer.masksToBounds = false
    }
    
    public func set(model: OnePastTransferViewModel) {
        onePastTransferCard.setupPastTransferCard(model)
    }
    
    public func set(delegate: OnePastTransferCardViewDelegate) {
        onePastTransferCard.delegate = delegate
    }
}
