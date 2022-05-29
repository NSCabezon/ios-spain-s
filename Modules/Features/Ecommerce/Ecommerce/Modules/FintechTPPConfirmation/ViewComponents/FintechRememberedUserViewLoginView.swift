//
//  FintechRememberedUserViewLoginView.swift
//  Ecommerce
//
//  Created by alvola on 19/04/2021.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

final class FintechRememberedUserViewLoginView: UIView {
    
    private lazy var dottedLineView: DottedLineView = {
        let view = DottedLineView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.lineDashPattern = [8, 4]
        view.strokeColor = .brownGray
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santander(size: 20.0)
        label.textColor = .black
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.configureText(withKey: "ecommerce_title_enterPassword")
        addSubview(label)
        return label
    }()

    private lazy var padView: EcommerceNumberPadLoginView = {
        let view = EcommerceNumberPadLoginView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setPadDelegate(_ delegate: EcommerceNumberPadLoginViewDelegate?) {
        padView.delegate = delegate
    }
}

private extension FintechRememberedUserViewLoginView {
    func setup() {
        configureDottedLineViewConstraints()
        configureTitleConstraints()
        configurePadConstraints()
        setAccesibilityIdentifiers()
    }
    
    func configureDottedLineViewConstraints() {
        NSLayoutConstraint.activate([
            dottedLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 49.0),
            self.trailingAnchor.constraint(equalTo: dottedLineView.trailingAnchor, constant: 49.0),
            dottedLineView.topAnchor.constraint(equalTo: self.topAnchor),
            dottedLineView.heightAnchor.constraint(equalToConstant: 1.0)
        ])
    }
    
    func configureTitleConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4.0),
            titleLabel.topAnchor.constraint(equalTo: dottedLineView.bottomAnchor, constant: Screen.isIphone4or5 ? 6.0 : 10.0),
            titleLabel.heightAnchor.constraint(equalToConstant: 26.0)
        ])
    }
    
    func configurePadConstraints() {
        NSLayoutConstraint.activate([
            padView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            padView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Screen.isIphone4or5 ? 5.0 : 10.0),
            padView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 8.0),
            padView.leadingAnchor.constraint(equalTo: leadingAnchor),
            padView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func setAccesibilityIdentifiers() {
        titleLabel.accessibilityIdentifier = AccessibilityFintechRememberedLoginView.titleLabel
    }
}
