//
//  HistoricalEmitted.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 02/04/2020.
//

import UI
import CoreFoundationLib

final class HistoricalTransferDateSectionView: UITableViewHeaderFooterView {
        
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var dateLabel: UILabel!
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        self.gestureRecognizers?.forEach({ removeGestureRecognizer($0) })
        super.addGestureRecognizer(gestureRecognizer)
    }
    
    func setupView() {
        self.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
    }
    
    func configure(withDate date: LocalizedStylableText) {
        self.dateLabel.textColor = .bostonRed
        self.dateLabel.font = .santander(family: .text, type: .bold, size: 14)
        self.dateLabel.configureText(withLocalizedString: date)
        self.separatorView.backgroundColor = UIColor.mediumSkyGray
        self.dateLabel.accessibilityIdentifier = AccessibilityTransferHistorical.historicalTransferLabelHeaderDate
    }
    
    func hideSeparator(_ hide: Bool) {
        self.separatorView.isHidden = hide
    }
}
