//
//  MonthReceiptsDateSectionCell.swift
//  Menu
//
//  Created by Ignacio González Miró on 09/06/2020.
//

import UIKit
import UI
import CoreFoundationLib

class MonthReceiptsDateSectionCell: UITableViewCell {
    
    @IBOutlet private weak var titleHeader: UILabel!
    
    static let identifier = "MonthReceiptsDateSectionCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }

    func configure(_ date: LocalizedStylableText) {
        self.titleHeader.configureText(withLocalizedString: date)
    }
}

private extension MonthReceiptsDateSectionCell {
    func setupView() {
        self.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        self.setTitle()
    }
    
    func setTitle() {
        self.titleHeader.font = UIFont.santander(family: .text, type: .bold, size: 14.0)
        self.titleHeader.textColor = .bostonRed
        self.titleHeader.textAlignment = .left
    }
}
