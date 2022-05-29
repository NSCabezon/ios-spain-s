//
//  TimeLineCollectionViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/21/20.
//

import UIKit
import CoreFoundationLib
import UI

class GotoTimeLineCollectionViewCell: UICollectionViewCell {
    static let identifier = "GotoTimeLineCollectionViewCell"
    @IBOutlet weak var timeLineImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.appearance()
    }
    
    func appearance() {
        self.titleLabel.textColor = .white
        self.descriptionLabel.textColor = .white
        self.viewContainer.backgroundColor = .darkTorquoise
        self.timeLineImageView.image = Assets.image(named: "icnBillsCalendar")
        self.titleLabel.text = localized("receiptsAndTaxes_text_financialAgenda")
        self.descriptionLabel.configureText(withKey: "receiptsAndTaxes_text_nextReceipts", andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85))
        self.drawBorder(cornerRadius: 5, color: .darkTorquoise, width: 1)
    }
}
