//
//  FinanceableTitleView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 25/08/2020.
//

import Foundation
import UI
import CoreFoundationLib

class FinanceableTitleView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
}

private extension FinanceableTitleView {
    func setAppearance() {
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.configureText(withKey: "financing_label_fractionalBill",
                                       andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 20)))
        self.titleLabel.accessibilityIdentifier = AccessibilityFinancingFractionalPurchases.title
    }
}
