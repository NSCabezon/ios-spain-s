//
//  BiometryValidatorFooterView.swift
//  BiometryValidator
//
//  Created by Rubén Márquez Fernández on 20/5/21.
//

import UIKit
import UI
import CoreFoundationLib

protocol BiometryValidatorFooterViewDelegate: class {
    func didTapInCancel()
    func didTapInRightButton(status: BiometryValidatorStatus)
}

final class BiometryValidatorFooterView: XibView {
    
    // MARK: - IBOutlets

    @IBOutlet private weak var footerStackView: UIStackView!
          
    // MARK: - Attributes

    weak var delegate: BiometryValidatorFooterViewDelegate?

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    // MARK: - Methods

    func configView(_ type: BiometryValidatorAuthType, status: BiometryValidatorStatus) {
        self.footerStackView.removeAllArrangedSubviews()
        self.addFooterWithTwoButtons(type, status: status)
    }
    
    func handleShadow(_ showShadow: Bool) {
        self.removeShadow()
        if Screen.isIphone4or5 {
            self.handleShadowIfNeeded()
        } else {
            if showShadow {
                self.handleShadowIfNeeded()
            } else {
                self.removeShadow()
            }
        }
    }
    
}

private extension BiometryValidatorFooterView {
    func setupView() {
        self.setColors()
        self.setAccessibilityIds()
    }
    
    // MARK: SetupView
    func setColors() {
        self.backgroundColor = .skyGray
        self.footerStackView.backgroundColor = .clear
    }
    
    func addFooterWithTwoButtons(_ type: BiometryValidatorAuthType, status: BiometryValidatorStatus) {
        let view = BiometryValidatorFooterWithTwoButtons()
        view.delegate = self
        view.config(type: type, status: status)
        self.footerStackView.addArrangedSubview(view)
    }
    
    func handleShadowIfNeeded() {
        self.drawShadow(offset: (x: 0, y: -2), opacity: 0.1, color: .black, radius: 4)
        self.layer.masksToBounds = false
    }
    
    func setAccessibilityIds() {
        self.accessibilityIdentifier = AccessibilityBiometryValidatorFooterView.baseView
    }
}

extension BiometryValidatorFooterView: DidTapInFooterWithTwoButtonsProtocol {
    func didTapInCancel() {
        self.delegate?.didTapInCancel()
    }

    func didTapInRightButton(status: BiometryValidatorStatus) {
        self.delegate?.didTapInRightButton(status: status)
    }
}
