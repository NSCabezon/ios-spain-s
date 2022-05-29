//
//  TransferAccountHeaderView.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 30/11/2020.
//

import UI
import CoreFoundationLib

final class TransferAccountHeaderView: UIDesignableView {
    
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    
    override func getBundleName() -> String {
        return "Transfer"
    }
    
    override func commonInit() {
        super.commonInit()
        configureLabel()
    }
    
    public func getCorrectHeight() -> CGFloat {
        headerLabel.sizeToFit()
        return headerLabel.frame.origin.y + headerLabel.frame.height + bottomConstraint.constant
    }
}

private extension TransferAccountHeaderView {
    func configureLabel() {
        headerLabel.setSantanderTextFont(type: .regular, size: 18, color: .lisboaGray)
        headerLabel.configureText(withKey: "originAccount_label_sentMoney")
        headerLabel.accessibilityIdentifier = AccessibilityTransferOrigin.titleLabel.rawValue
    }
}
