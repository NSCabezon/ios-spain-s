//
//  BiometryValidatorActionView.swift
//  BiometryValidator
//
//  Created by Rubén Márquez Fernández on 21/5/21.
//

import UIKit
import UI
import CoreFoundationLib

protocol BiometryValidatorActionViewDelegate: AnyObject {
    func didTapInSign()
    func didTapInImage()
}

public final class BiometryValidatorActionView: XibView {
    
    // MARK: - IBOutlets

    @IBOutlet private weak var topImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    
    // MARK: - Attributes

    weak var delegate: BiometryValidatorActionViewDelegate?

    // MARK: - Initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    // MARK: - Actions

    @IBAction func actionSign(_ sender: UIButton) {
        self.delegate?.didTapInSign()
    }
    
    @objc func imageTapped(_ sender: UIImageView) {
        self.delegate?.didTapInImage()
    }
    
    // MARK: - Methods

    func configView(_ type: BiometryValidatorAuthType, status: BiometryValidatorStatus) {
        self.stackView.removeAllArrangedSubviews()
        self.configTopImage(type, status: status)
        self.configTitle(type)
        self.configStackView(type, status: status)
    }
}

private extension BiometryValidatorActionView {
    func setupView() {
        self.backgroundColor = .clear
        self.setTitle()
        self.setAccessibilityIds()
    }
    
    func setTitle() {
        self.titleLabel.font = UIFont.santander(family: .text, type: .regular, size: 18)
        self.titleLabel.textAlignment = .center
        self.titleLabel.numberOfLines = 0
    }
    
    func configTopImage(_ type: BiometryValidatorAuthType, status: BiometryValidatorStatus) {
        let image = Assets.image(named: type.imageName())
        topImageView.image = image?.withRenderingMode(.alwaysTemplate)
        topImageView.tintColor = .brownGray
        topImageView.isUserInteractionEnabled = status != .identifying
        guard topImageView.gestureRecognizers?.count != 0 else { return }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        topImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func configTitle(_ type: BiometryValidatorAuthType) {
        let localizedKey = type.titleText()
        self.titleLabel.configureText(withKey: localizedKey)
        self.titleLabel.textColor = .lisboaGray
    }
    
    func configStackView(_ type: BiometryValidatorAuthType, status: BiometryValidatorStatus) {
        switch status {
        case .confirm:
            self.addSignView()
        case .identifying:
            self.addLoadingView()
        case .error:
            self.addErrorView(type)
            self.addSignView()
        }
    }
    
    func addSignView() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        button.setTextAligment(.center, for: .normal)
        button.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 14)
        button.setTitle(localized("ecommerce_button_useElectronicSignature"), for: .normal)
        button.setTitleColor(.darkTorquoise, for: .normal)
        button.addTarget(self, action: #selector(actionSign), for: .touchUpInside)
        self.stackView.addArrangedSubview(button)
    }
    
    func addLoadingView() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.textAlignment = .center
        label.textColor = .lisboaGray
        label.font = UIFont.santander(family: .text, type: .regular, size: 16)
        label.configureText(withKey: "ecommerce_label_identifying")
        self.stackView.addArrangedSubview(label)
    }
    
    func addErrorView(_ type: BiometryValidatorAuthType) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.textAlignment = .center
        label.textColor = .bostonRed
        label.font = UIFont.santander(family: .text, type: .regular, size: 16)
        label.configureText(withKey: type.errorText())
        self.stackView.addArrangedSubview(label)
    }
    
    func setAccessibilityIds() {
        self.accessibilityIdentifier = AccessibilityBiometryValidatorActionView.baseView
        self.topImageView.accessibilityIdentifier = AccessibilityBiometryValidatorActionView.topImageView
        self.titleLabel.accessibilityIdentifier = AccessibilityBiometryValidatorActionView.titleLabel    }
}
