//
//  LoginFooterBiometricsView.swift
//  UI
//
//  Created by Ignacio González Miró on 9/3/21.
//

import UIKit
import CoreFoundationLib

final public class LoginFooterBiometricsView: XibView {
    @IBOutlet private weak var biometricsImageView: UIImageView!
    @IBOutlet private weak var biometricsLabel: UILabel!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ type: LoginFooterType) {
        let localizedConfiguration = LocalizedStylableTextConfiguration(font: UIFont.santander(family: .text, type: .regular, size: 14), alignment: .left, lineHeightMultiple: 0.8, lineBreakMode: .byWordWrapping)
        switch type {
        case .code:
            self.setBiometricsView(with: "icnKeyboardLogin", key: "login_button_password", localizedConfiguration: localizedConfiguration)
        case .faceId:
            self.setBiometricsView(with: "smallFaceId", key: "loginRegistered_faceId_access", localizedConfiguration: localizedConfiguration)
        case .fingerPrint:
            self.setBiometricsView(with: "smallFingerprint", key: "loginRegistered_fingerprint_access", localizedConfiguration: localizedConfiguration)
        case .none:
            self.isHidden = true
        }
    }
}

private extension LoginFooterBiometricsView {
    func setupView() {
        self.backgroundColor = .clear
        self.setTitle()
        self.setAccessibilityIds()
    }
    
    func setTitle() {
        self.biometricsLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        self.biometricsLabel.numberOfLines = 0
        self.biometricsLabel.textColor = .white
    }
    
    func setAccessibilityIds() {
        self.biometricsImageView.accessibilityIdentifier = AccessibilityLoginFooter.BiometricsView.image
        self.biometricsLabel.accessibilityIdentifier = AccessibilityLoginFooter.BiometricsView.text
    }
    
    func setBiometricsView(with imageNamed: String, key: String, localizedConfiguration: LocalizedStylableTextConfiguration) {
        self.biometricsImageView.image = Assets.image(named: imageNamed)
        self.biometricsLabel.configureText(withKey: key, andConfiguration: localizedConfiguration)
    }
}
