//
//  FintechConfirmationView.swift
//  Ecommerce
//
//  Created by alvola on 16/04/2021.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

protocol FintechHomeViewDelegate: FintechChangeUseDelegate {
    func didPressUseAccessCode()
    func didPressBiometryIcon()
}

final class FintechHomeView: UIView {
    
    private lazy var greetingsView: FintechConfirmationGreetingView = {
        let view = FintechConfirmationGreetingView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()
    
    private lazy var dottedLine1View: DottedLineView = {
        let view = DottedLineView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.lineDashPattern = [8, 4]
        view.strokeColor = .brownGray
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santander(type: .light, size: Screen.isIphone4or5 ? 14.0 : 20.0)
        label.textColor = .lisboaGray
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.configureText(withLocalizedString: localized("ecommerce_label_sanIdentification"))
        addSubview(label)
        return label
    }()
    
    private lazy var dottedLine2View: DottedLineView = {
        let view = DottedLineView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.lineDashPattern = [8, 4]
        view.strokeColor = .brownGray
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var confirmationMethodView: FintechConfirmationMethodView = {
        let view = FintechConfirmationMethodView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.biometryIconAction = {
            self.delegate?.didPressBiometryIcon()
        }
        return view
    }()
    
    private weak var delegate: FintechHomeViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setDelegate(_ delegate: FintechHomeViewDelegate) {
        self.delegate = delegate
        greetingsView.delegate = delegate
    }
    
    func setStatus(_ status: EcommerceAuthStatus, type: EcommerceAuthType, paymentStatus: EcommercePaymentStatus?) {
        confirmationMethodView.setConfirmationMethod(type, status: status)
    }
    
    func setPaymentStatus(_ status: EcommercePaymentStatus) {
        confirmationMethodView.setPaymentStatus(status)
    }
    
    func setUsername(_ username: String?) {
        greetingsView.setUsername(username)
    }
}

private extension FintechHomeView {
    func setup() {
        configureGreetingsViewConstraints()
        configureDottedLine1ViewConstraints()
        configureInfoLabelConstraints()
        configureDottedLine2ViewConstraints()
        configureConfirmationMethodViewConstraints()
        setAccessibilityIdentifiers()
    }
    
    func configureGreetingsViewConstraints() {
        NSLayoutConstraint.activate([
            greetingsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: greetingsView.trailingAnchor),
            greetingsView.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    func configureDottedLine1ViewConstraints() {
        NSLayoutConstraint.activate([
            dottedLine1View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 26.0),
            trailingAnchor.constraint(equalTo: dottedLine1View.trailingAnchor, constant: 26.0),
            dottedLine1View.topAnchor.constraint(equalTo: greetingsView.bottomAnchor),
            dottedLine1View.heightAnchor.constraint(equalToConstant: 1.0)
        ])
    }
    
    func configureInfoLabelConstraints() {
        NSLayoutConstraint.activate([
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18.0),
            trailingAnchor.constraint(equalTo: infoLabel.trailingAnchor, constant: 18.0),
            infoLabel.topAnchor.constraint(equalTo: dottedLine1View.bottomAnchor, constant: 11.0)
        ])
    }
    
    func configureDottedLine2ViewConstraints() {
        NSLayoutConstraint.activate([
            dottedLine2View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 26.0),
            trailingAnchor.constraint(equalTo: dottedLine2View.trailingAnchor, constant: 26.0),
            dottedLine2View.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 11.0),
            dottedLine2View.heightAnchor.constraint(equalToConstant: 1.0)
        ])
    }
    
    func configureConfirmationMethodViewConstraints() {
        NSLayoutConstraint.activate([
            confirmationMethodView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: confirmationMethodView.trailingAnchor),
            confirmationMethodView.topAnchor.constraint(equalTo: dottedLine2View.bottomAnchor),
            confirmationMethodView.heightAnchor.constraint(equalToConstant: 137.0),
            bottomAnchor.constraint(equalTo: confirmationMethodView.bottomAnchor)
        ])
    }
    
    func setAccessibilityIdentifiers() {
        infoLabel.accessibilityIdentifier = AccessibilityFintechConfirmationView.sanIdentLabel
    }
    
    @objc func useCodeDidPress() {
        delegate?.didPressUseAccessCode()
    }
}
