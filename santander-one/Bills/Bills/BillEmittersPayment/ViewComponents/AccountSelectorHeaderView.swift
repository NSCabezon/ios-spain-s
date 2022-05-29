//
//  AccountSelectorHeaderView.swift
//  Bills
//
//  Created by Carlos Monfort Gómez on 21/05/2020.
//

import Foundation
import CoreFoundationLib
import UI

final class AccountSelectorHeaderView: XibView {
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppareance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppareance()
    }
}

private extension AccountSelectorHeaderView {
    func setAppareance() {
        self.headerTitleLabel.setSantanderTextFont(size: 18, color: .lisboaGray)
        self.headerTitleLabel.configureText(withKey: "receiptsAndTaxes_label_whatAccount")
        self.headerTitleLabel.accessibilityIdentifier = "receiptsAndTaxes_label_whatAccount"
    }
}
