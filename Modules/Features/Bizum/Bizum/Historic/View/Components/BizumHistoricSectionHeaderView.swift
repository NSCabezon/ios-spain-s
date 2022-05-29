//
//  BizumHistoricSectionHeaderView.swift
//  Bizum
//
//  Created by Jose Ignacio de Juan Díaz on 28/10/2020.
//

import UIKit

final class BizumHistoricSectionHeaderView: UITableViewHeaderFooterView {
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    static let identifier = "BizumHistoricSectionHeaderView"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
        self.setAccessibilityIdentifiers()
    }
    
    func configView() {
        self.separatorView.backgroundColor = .mediumSkyGray
        self.titleLabel.setHeadlineTextFont(type: .bold, size: 14, color: .bostonRed)
        self.titleLabel.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricLabelHistoricListDate
    }
        
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    func hideSeparator(_ isHidden: Bool) {
        self.separatorView.isHidden = isHidden
    }
}

private extension BizumHistoricSectionHeaderView {
    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = BizumHistoricSectionHeader.bizumLabelTitle
    }
}
