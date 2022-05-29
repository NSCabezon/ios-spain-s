//
//  FintechConfirmationGreetingView.swift
//  Ecommerce
//
//  Created by alvola on 16/04/2021.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

protocol FintechChangeUseDelegate: class {
    func didPressChangeUser()
}

final class FintechConfirmationGreetingView: UIView {

    private lazy var userNameGreetingsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santander(size: 20)
        label.textColor = .lisboaGray
        label.textAlignment = .center
        addSubview(label)
        return label
    }()

    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santander(size: 14)
        label.textColor = .lisboaGray
        label.text = localized("ecommerce_label_externalIdentification")
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        addSubview(label)
        return label
    }()
    
    private lazy var changeUserButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        button.setTitle(localized("ecommerce_button_changeUser"),
                        for: .normal)
        button.setTitleColor(.darkTorquoise, for: .normal)
        button.titleLabel?.font = UIFont.santander(size: 14.0)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(didPressChangeUser), for: .touchUpInside)
        return button
    }()
    
    private lazy var changeUserButtonHeightConstraint: NSLayoutConstraint = {
        changeUserButton.heightAnchor.constraint(equalToConstant: 17.0)
    }()
    
    private lazy var changeUserButtonBottomConstraint: NSLayoutConstraint = {
        self.bottomAnchor.constraint(equalTo: changeUserButton.bottomAnchor, constant: 18.0)
    }()
    
    weak var delegate: FintechChangeUseDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setUsername(_ userName: String?) {
        guard let name = userName else { return configureForNoUser() }
        userNameGreetingsLabel.configureText(withLocalizedString: localized("ecommerce_label_hello",
                                                                            [StringPlaceholder(.name, name)]))
    }
}

private extension FintechConfirmationGreetingView {

    func setup() {
        configureUserNameGreetingsLabelConstraints()
        configureInfoLabelConstraints()
        configureChangeUserButton()
        setAccessibilityIdentifiers()
    }
    
    func configureUserNameGreetingsLabelConstraints() {
        NSLayoutConstraint.activate([
            userNameGreetingsLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            userNameGreetingsLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.0),
            userNameGreetingsLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 22.0),
            userNameGreetingsLabel.heightAnchor.constraint(equalToConstant: 22.0)
        ])
    }
    
    func configureInfoLabelConstraints() {
        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            infoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.0),
            infoLabel.topAnchor.constraint(equalTo: userNameGreetingsLabel.bottomAnchor, constant: 8.0)
        ])
    }
    
    func configureChangeUserButton() {
        NSLayoutConstraint.activate([
            changeUserButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            changeUserButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 5.0),
            changeUserButtonHeightConstraint,
            changeUserButtonBottomConstraint
        ])
    }
    
    func configureForNoUser() {
        userNameGreetingsLabel.isHidden = true
        changeUserButton.isHidden = true
        changeUserButtonHeightConstraint.constant = 0.0
        changeUserButtonBottomConstraint.constant = 8.0
    }
    
    func setAccessibilityIdentifiers() {
        userNameGreetingsLabel.accessibilityIdentifier = AccessibilityFintechConfirmationView.greetingLabel
        infoLabel.accessibilityIdentifier = AccessibilityFintechConfirmationView.externalIdentLabel
        changeUserButton.accessibilityIdentifier = AccessibilityFintechConfirmationView.changeUserButton
    }
    
    @objc func didPressChangeUser() {
        delegate?.didPressChangeUser()
    }
}
