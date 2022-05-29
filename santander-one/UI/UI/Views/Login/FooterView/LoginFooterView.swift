//
//  LoginFooterView.swift
//  UI
//
//  Created by Ignacio González Miró on 9/3/21.
//

import UIKit
import CoreFoundationLib

enum LoginFooterType {
    case code
    case fingerPrint
    case faceId
    case none
}

protocol DidTapInLoginFooterButtonsDelegate: AnyObject {
    func didTapInBiometrics(_ type: LoginFooterType)
    func didTapInRecovery()
    func didTapInEcommerce()
}

final class LoginFooterView: XibView {
    @IBOutlet private weak var biometricsView: LoginFooterBiometricsView!
    @IBOutlet private weak var ecommerceButton: UIButton!
    @IBOutlet private weak var recoveryKeyView: LoginFooterRecoveryView!
    @IBOutlet private weak var labelLogo: UILabel!
    private var displayEcommerce: Bool = false

    weak var delegate: DidTapInLoginFooterButtonsDelegate?
    var type: LoginFooterType?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateEcommerceState()
    }
    
    func configType(_ type: LoginFooterType) {
        self.type = type
        self.biometricsView.configView(type)
        self.recoveryKeyView.showsRecoveryView(type)
    }
    
    func configEcommerceButton(_ isEnabled: Bool) {
        self.displayEcommerce = isEnabled
        self.updateEcommerceState()
        guard isEnabled else { return }
        self.ecommerceButton.setImage(Assets.image(named: "icnSantanderKeyLock"), for: .normal)
    }

    @IBAction func didTapInEcommerce(_ sender: Any) {
        delegate?.didTapInEcommerce()
    }
}

private extension LoginFooterView {
    func setupView() {
        self.backgroundColor = .clear
        self.clipsToBounds = false
        self.addGestureRecognizerToBiometricsView()
        self.addGestureRecognizerToRecoveryView()
        self.addLogoLabel()
        self.setAccessibilityIds()
    }
    
    func setAccessibilityIds() {
        self.accessibilityIdentifier = AccessibilityLoginFooter.baseView
        self.biometricsView.accessibilityIdentifier = AccessibilityLoginFooter.biometricsView
        self.ecommerceButton.accessibilityIdentifier = AccessibilityLoginFooter.ecommerceButton
        self.recoveryKeyView.accessibilityIdentifier = AccessibilityLoginFooter.recoveryKeyView
        self.labelLogo.accessibilityIdentifier = "login_button_santanderKey"
    }
    
    func addGestureRecognizerToBiometricsView() {
        self.biometricsView.gestureRecognizers?.removeAll()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInBiometrics))
        self.biometricsView.addGestureRecognizer(tap)
    }
    
    func addGestureRecognizerToRecoveryView() {
        self.recoveryKeyView.gestureRecognizers?.removeAll()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInRecovery))
        self.recoveryKeyView.addGestureRecognizer(tap)
    }

    func addLogoLabel() {
        self.labelLogo.configureText(withKey: "login_button_santanderKey")
        let labelTextConfiguration = LocalizedStylableTextConfiguration(font: UIFont.santander(size: 11), alignment: .center, lineHeightMultiple: 0.75)
        self.labelLogo.configureText(withKey: "login_button_santanderKey",
                                             andConfiguration: labelTextConfiguration)
        self.labelLogo.textColor = .white
        self.labelLogo.sizeToFit()
    }
    
    @objc func didTapInBiometrics() {
        guard let type = self.type else {
            return
        }
        delegate?.didTapInBiometrics(type)
    }
    
    @objc func didTapInRecovery() {
        delegate?.didTapInRecovery()
    }

    func updateEcommerceState() {
        self.ecommerceButton.isHidden = !self.displayEcommerce
        if let convertedLabelFrame = self.view?.window?.convert(self.labelLogo.frame, from: self.view) {
            self.labelLogo.isHidden = !UIScreen.main.bounds.contains(convertedLabelFrame) || !self.displayEcommerce // Only visible if fits
        } else {
            self.labelLogo.isHidden = true
        }
    }
}
