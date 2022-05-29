//
//  DateTableSectionView.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/24/20.
//

import Foundation
import CoreFoundationLib

final class DateTableSectionHeaderView: UITableViewHeaderFooterView {
    static let identifier = "DateTableSectionHeaderView"
    private var view: UIView?
    @IBOutlet weak var dateLabel: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        super.contentView.backgroundColor = .white
        self.dateLabel.textColor = .bostonRed
        self.setAccessibilityIdentifiers()
    }
    
    func setDate(dateString: LocalizedStylableText?) {
        self.dateLabel.configureText(withLocalizedString: dateString ?? .empty)
    }
}

private extension DateTableSectionHeaderView {
    private func setAccessibilityIdentifiers() {
        self.dateLabel.accessibilityIdentifier = AccesibilityBills.LastBillHeaderView.lastBillDateTextView
    }
}
