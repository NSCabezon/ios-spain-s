//
//  FintechUnrememberedUserViewLoginView.swift
//  Ecommerce
//
//  Created by alvola on 19/04/2021.
//

import UIKit
import UI
import ESCommons
import CoreFoundationLib

protocol FintechUnrememberedUserLoginViewDelegate: class {
    func confirmed(withType type: String, documentNumber: String, accessKey: String)
}

final class FintechUnrememberedUserLoginView: UIView {
    
    weak var delegate: FintechUnrememberedUserLoginViewDelegate?

    private lazy var documentTextField: DocumentTextField = {
        let textField = DocumentTextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.docTextDelegate = self
        textField.style = DocumentTextFieldConfiguration.whiteConfig()
        textField.setPlaceholder(localized("login_hint_documentNumber").text)
        textField.textField?.tintColor = .lisboaGray
        addSubview(textField)
        return textField
    }()
    
    private lazy var loginDropDownView: LoginDropDownView = {
        let view = LoginDropDownView()
        addSubview(view)
        bringSubviewToFront(view)
        view.setUpDropDown(viewPositionReference: documentTextField.frame)
        view.selectionColor = .lightSanGray
        view.delegate = self
        view.accessibilityIdentifier = AccessibilityFintechUnrememberedLoginView.dropList
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
        view.delegate = self
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == self && self.loginDropDownView.getIsDropDownPresent() {
            self.dropDownButtonDidPressed()
        }
        self.endEditing(true)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

}

extension FintechUnrememberedUserLoginView: EcommerceNumberPadLoginViewDelegate {
    
    func didTapOnOK(withMagic magic: String) {
        delegate?.confirmed(withType: documentTextField.loginType.metricsValue,
                                documentNumber: documentTextField.introducedText,
                                accessKey: magic)
    }
}

private extension FintechUnrememberedUserLoginView {
    func setup() {
        self.clipsToBounds = false
        configureDottedLineViewConstraints()
        configureTitleConstraints()
        configurePadConstraints()
        setAccesibilityIdentifiers()
    }
    
    func configureDottedLineViewConstraints() {
        NSLayoutConstraint.activate([
            documentTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.0),
            self.trailingAnchor.constraint(equalTo: documentTextField.trailingAnchor, constant: 16.0),
            documentTextField.topAnchor.constraint(equalTo: self.topAnchor),
            documentTextField.heightAnchor.constraint(equalToConstant: Screen.isIphone4or5 ? 45.0 : 48.0)
        ])
    }
    
    func configureTitleConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4.0),
            titleLabel.topAnchor.constraint(equalTo: documentTextField.bottomAnchor, constant: Screen.isIphone4or5 ? 6.0 : 10.0),
            titleLabel.heightAnchor.constraint(equalToConstant: 26.0)
        ])
    }
    
    func configurePadConstraints() {
        NSLayoutConstraint.activate([
            padView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            padView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Screen.isIphone4or5 ? 5.0 : 10.0),
            padView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 8.0)
        ])
    }
    
    func setAccesibilityIdentifiers() {
        titleLabel.accessibilityIdentifier = AccessibilityFintechUnrememberedLoginView.titleLabel
        documentTextField.accessibilityIdentifier = AccessibilityFintechUnrememberedLoginView.textField
    }
}

extension FintechUnrememberedUserLoginView: DocumentTextProtocol {
    public func dropDownButtonDidPressed() {
        if !loginDropDownView.getIsDropDownPresent() {
            bringSubviewToFront(loginDropDownView)
        }
        loginDropDownView.toogleDropDown()
        documentTextField.setPlaceholder((loginDropDownView.getIsDropDownPresent() ?
                                            localized("login_text_selectDocument"):
                                            localized( "login_hint_documentNumber")).text)
        self.documentTextField.setDocumentTextField(type: loginDropDownView.getTypeSelected(),
                                                    isDropDownPresent: loginDropDownView.getIsDropDownPresent())
    }
}

extension FintechUnrememberedUserLoginView: DropDownProtocol {
    public func loginTypeSelected(type: LoginIdentityDocumentType) {
        documentTextField.setLoginType(type)
        documentTextField.setPlaceholder(localized("login_hint_documentNumber").text)
        documentTextField.setDocumentTextField(type: type,
                                               isDropDownPresent: loginDropDownView.getIsDropDownPresent())
    }
}
