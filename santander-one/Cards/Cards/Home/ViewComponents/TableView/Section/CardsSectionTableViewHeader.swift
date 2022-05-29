//
//  CardsSectionTableViewHeader.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/25/19.
//

import UIKit
import CoreFoundationLib

class CardsSectionTableViewHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var horizontalLine: UIView!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        self.layer.backgroundColor = UIColor.white.withAlphaComponent(0.9).cgColor
    }
    
    func configure(withDate date: LocalizedStylableText) {
        dateLabel.font = .santander(family: .text, type: .bold, size: 14)
        dateLabel.textColor = .bostonRed
        dateLabel.configureText(withLocalizedString: date)
    }
}

extension CardsSectionTableViewHeader {
    public func toggleHorizontalLine(toVisible visible: Bool) {
        horizontalLine.isHidden = !visible
    }
}
