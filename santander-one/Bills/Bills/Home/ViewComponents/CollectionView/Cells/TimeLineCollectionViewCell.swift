//
//  TimeLineCollectionViewCell.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/21/20.
//

import UIKit
import CoreFoundationLib
import UI

class TimeLineCollectionViewCell: UICollectionViewCell {
    static let identifier = "TimeLineCollectionViewCell"
    @IBOutlet weak var timeLineImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.appearance()
        self.setAccessibilityIdentifiers()
    }
    
}

private extension TimeLineCollectionViewCell {
    func appearance() {
        self.titleLabel.textColor = .white
        self.descriptionLabel.textColor = .white
        self.viewContainer.backgroundColor = .darkTorquoise
        self.timeLineImageView.image = Assets.image(named: "icnBillsCalendar")
        self.titleLabel.text = localized("receiptsAndTaxes_text_financialAgenda")
        self.drawBorder(cornerRadius: 5, color: .darkTorquoise, width: 1)
        self.descriptionLabel.configureText(withKey: "receiptsAndTaxes_text_nextReceipts",
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 12),
                                                                                                 lineHeightMultiple: 0.85))
    }
    
    private func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccesibilityBills.FutureBillTimeLineView.showTimelineItemTitle
        self.descriptionLabel.accessibilityIdentifier = AccesibilityBills.FutureBillTimeLineView.showTimelineItemSubtitle
    }
}
