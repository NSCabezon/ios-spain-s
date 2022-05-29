//
//  FinanceableTableViewHeader.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 6/30/20.
//

import UI
import CoreFoundationLib
import Foundation

final class FinanceableTableViewHeader: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension FinanceableTableViewHeader {
    func setupView() {
        self.titleLabel.text = localized("financing_label_movements").uppercased()
        self.dividerView.backgroundColor = UIColor.mediumSkyGray
    }
}
