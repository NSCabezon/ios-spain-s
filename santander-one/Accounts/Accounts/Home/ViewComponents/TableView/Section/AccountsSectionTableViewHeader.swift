//
//  AccountsSectionTableViewHeader.swift
//  Accounts
//
//  Created by Juan Carlos López Robles on 11/7/19.
//

import CoreFoundationLib
import UI

class AccountsSectionTableViewHeader: UITableViewHeaderFooterView {
    
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
        dateLabel.textColor = .bostonRed
        dateLabel.configureText(withLocalizedString: date,
                                andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 14)))
    }
}

extension AccountsSectionTableViewHeader {
    public func toggleHorizontalLine(toVisible visible: Bool) {
        horizontalLine.isHidden = !visible
    }
}
