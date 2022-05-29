//
//  LoginFooterRecoveryView.swift
//  UI
//
//  Created by Ignacio González Miró on 9/3/21.
//

import UIKit
import CoreFoundationLib

public final class LoginFooterRecoveryView: XibView {
    @IBOutlet private weak var recoveryLabel: UILabel!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func showsRecoveryView(_ type: LoginFooterType) {
        self.isHidden = false
        switch type {
        case .code:
            self.isHidden = true
        case .faceId, .fingerPrint, .none:
            self.isHidden = false
        }
    }
}

private extension LoginFooterRecoveryView {
    func setupView() {
        self.backgroundColor = .clear
        self.setTitle()
        self.configView()
    }
    
    func setTitle() {
        self.recoveryLabel.numberOfLines = 0
        self.recoveryLabel.textColor = .white
    }
    
    func setAccessibilityIds() {
        self.recoveryLabel.accessibilityIdentifier = AccessibilityLoginFooter.RecoveryView.text
    }
    
    func configView() {
        let localizedConfiguration = LocalizedStylableTextConfiguration(font: UIFont.santander(family: .text, type: .regular, size: 14), alignment: .right, lineHeightMultiple: 0.8, lineBreakMode: .byWordWrapping)
        self.recoveryLabel.configureText(withKey: "login_button_retrieveKey", andConfiguration: localizedConfiguration)
    }
}
