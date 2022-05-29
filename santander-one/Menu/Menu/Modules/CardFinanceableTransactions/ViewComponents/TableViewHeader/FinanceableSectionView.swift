//
//  FinanceableSectionView.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 6/30/20.
//

import UI
import CoreFoundationLib
import Foundation

final class FinanceableSectionView: UITableViewHeaderFooterView {
    static let identifier = "FinanceableSectionView"
    @IBOutlet weak var dateLabel: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppearance()
    }
    
    func setLocalizedDate(_ localizedDate: LocalizedStylableText?) {
        self.dateLabel.configureText(withLocalizedString: localizedDate ?? .empty)
    }
}

private extension FinanceableSectionView {
    func setAppearance() {
        self.dateLabel.font = .santander(family: .text, type: .bold, size: 14)
        self.dateLabel.textColor = .santanderRed
        super.contentView.backgroundColor = .white
    }
}
