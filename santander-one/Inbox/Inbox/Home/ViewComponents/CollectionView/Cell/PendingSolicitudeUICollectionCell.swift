//
//  PendingSolicitudeUICollectionCell.swift
//  Inbox
//
//  Created by Juan Carlos López Robles on 1/20/20.
//

import UIKit
import UI
import CoreFoundationLib

class PendingSolicitudeUICollectionCell: UICollectionViewCell {
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var pendintTitleLabel: UILabel!
    @IBOutlet weak var pendingDescriptionLabel: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 6
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.lightSanGray.cgColor
        self.viewContainer.drawBorder(cornerRadius: 6, color: UIColor.lightSkyBlue, width: 1)
    }
    
    func configure(_ viewModel: PendingSolicitudeInboxViewModel) {
        self.headerTitle.text = localized("contracts_label_pending")
        self.iconImageView.image = Assets.image(named: "icnPendingSignature")
        self.pendintTitleLabel.text = viewModel.name
        self.pendingDescriptionLabel.configureText(withLocalizedString: viewModel.entity.expirationDate?.timeRemainingInbox ?? LocalizedStylableText.empty)
    }
}
