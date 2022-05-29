//
//  AccountProductDetailEditableView.swift
//  Account
//
//  Created by crodrigueza on 9/4/21.
//

import Foundation
import UI
import UIKit
import CoreFoundationLib

final class AccountProductDetailEditableView: XibView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var valueLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var editImageView: UIImageView!
    @IBOutlet private weak var editAliasTextField: LisboaTextFieldWithErrorView!
    @IBOutlet private weak var editAliasHeightConstraint: NSLayoutConstraint!
    private var textField: LisboaTextField { return editAliasTextField.textField }
    private var aliasTextFieldSize: Int = 20
    private let errorMessageKey = "accountDetail_label_aliasError"
    private var account: AccountDetailDataViewModel?
    private var regExValidatorString: CharacterSet?
    weak var delegate: AccountProductDetailEditableViewDelegate?
    private var titleAccessibilityID: String?
    private var valueAccessibilityID: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupViewModel(account: AccountDetailDataViewModel, title: String, value: String, titleAccessibilityID: String? = nil, valueAccessibilityID: String? = nil, maxLengthString: Int?, regExValidatorString: CharacterSet?) {
        self.account = account
        self.titleLabel?.text = title
        self.valueLabel.text = value
        if let maxLengthString = maxLengthString {
            self.aliasTextFieldSize = maxLengthString
        }
        if let regExValidatorString = regExValidatorString {
            self.regExValidatorString = regExValidatorString
        }
        self.titleAccessibilityID = titleAccessibilityID
        self.valueAccessibilityID = valueAccessibilityID
        self.setAccessibilityIdentifiers()
    }
}

private extension AccountProductDetailEditableView {
    private var texfieldStyle: LisboaTextFieldStyle {
        var style = LisboaTextFieldStyle.default
        style.fieldFont = .santander(family: .text, type: .regular, size: 17)
        style.fieldTextColor = .lisboaGray
        return style
    }
    
    // MARK: - Setup
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.titleLabel.textColor = .brownishGray
        self.valueLabel.font = .santander(family: .text, type: .bold, size: 16)
        self.valueLabel.textColor = .lisboaGray
        self.editImageView.image = Assets.image(named: "icnEdit")
        self.setupDetailEditableView()
        self.hideEditAliasTextField(true)
        self.imageEditTapped()
        self.setAccessibilityLabels()
    }
    
    func setAccessibilityIdentifiers() {
        self.view?.accessibilityIdentifier = AccessibilityAccountDetail.detailView
        self.titleLabel.accessibilityIdentifier = titleAccessibilityID != nil ? titleAccessibilityID : AccessibilityAccountDetail.titleDetail
        self.valueLabel.accessibilityIdentifier = valueAccessibilityID != nil ? valueAccessibilityID : AccessibilityAccountDetail.subtitleDetail
        self.editImageView.accessibilityIdentifier = AccessibilityAccountDetail.editIconDetail
        self.editAliasTextField.accessibilityIdentifier = AccessibilityAccountDetail.editAliasTextFieldDetail
    }
    
    func setAccessibilityLabels() {
        self.editImageView.accessibilityLabel = localized(AccessibilityAccountDetail.editAlias)
        self.editImageView.accessibilityTraits = .button
    }
    
    // MARK: - UI Setup
    func setupDetailEditableView() {
        self.setupTextField()
        self.setupRightButton()
    }
    
    func setupTextField() {
        let textFieldFormmater = UIFormattedCustomTextField()
        if let regExValidatorString = regExValidatorString {
            textFieldFormmater.setAllowOnlyCharacters(regExValidatorString)
        } else {
            textFieldFormmater.setAllowOnlyCharacters(.alias)
        }
        textFieldFormmater.setMaxLength(maxLength: self.aliasTextFieldSize)
        let configuration = LisboaTextField.WritableTextField(type: .simple,
                                                              formatter: textFieldFormmater,
                                                              disabledActions: [],
                                                              keyboardReturnAction: nil,
                                                              textfieldCustomizationBlock: nil)
        let editingStyle = LisboaTextField.EditingStyle.writable(configuration: configuration)
        self.textField.setEditingStyle(editingStyle)
        if let alias = self.valueLabel.text {
            self.textField.setText(alias)
        }
        self.textField.setStyle(texfieldStyle)
    }
    
    func setupRightButton() {
        let button = UIButton()
        button.backgroundColor = .darkTorquoise
        button.layer.cornerRadius = 6.0
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.santander(family: .text, type: .bold, size: 14), .foregroundColor: UIColor.white]
        let attributedText = NSAttributedString(string: localized("generic_link_ok"), attributes: attributes)
        button.setAttributedTitle(attributedText, for: .normal)
        button.widthAnchor.constraint(equalToConstant: 41).isActive = true
        button.addTarget(self, action: #selector(self.didTouchSaveAliasButton), for: .touchUpInside)
        self.textField.setRightAccessory(.view(button))
    }
    
    func setupValueLabelBottomConstraint(_ value: CGFloat) {
        self.valueLabelBottomConstraint.constant = value
    }
    
    func hideEditAliasTextField(_ hide: Bool) {
        self.editAliasTextField.isHidden = hide
        self.valueLabel.isHidden = !hide
        self.editImageView.isHidden = !hide
        if hide {
            self.setupValueLabelBottomConstraint(17.5)
        } else {
            self.setupValueLabelBottomConstraint(64.5)
            self.setupTextField()
        }
    }
    
    func setUpLisboaTextFieldHeight(_ value: CGFloat) {
        self.editAliasHeightConstraint.constant = value
    }
    
    @objc func hideKeyboard() {
        _ = self.textField.resignFirstResponder()
    }
    
    // MARK: - Checking
    func isAliasCorrect(_ alias: String) -> Bool {
        if alias.count > self.aliasTextFieldSize || alias.count == 0 {
            self.showError(self.errorMessageKey)
            return false
        } else {
            self.hideError()
            return true
        }
    }
    
    // MARK: - Actions
    func imageEditTapped() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doEdit(tapGestureRecognizer:)))
        self.editImageView.isUserInteractionEnabled = true
        self.editImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func doEdit(tapGestureRecognizer: UITapGestureRecognizer) {
        self.hideEditAliasTextField(false)
        self.hideError()
        self.textField.setTextFieldFocus()
    }
    
    @objc func didTouchSaveAliasButton() {
        guard let newAlias = self.textField.text else { return }
        guard let account = account else { return }
        if self.isAliasCorrect(newAlias) {
            self.delegate?.didTapOnEdit(account: account, alias: newAlias)
            self.hideEditAliasTextField(true)
            self.valueLabel.text = newAlias
        } else {
            self.showError(self.errorMessageKey)
        }
        self.hideKeyboard()
    }
}

extension AccountProductDetailEditableView {
    var identifier: String {
        return "ALIAS"
    }
    
    // MARK: - Error View
    func showError(_ error: String?) {
        self.titleLabel.textColor = .bostonRed
        self.editAliasTextField.showError(error ?? "")
        self.setUpLisboaTextFieldHeight(60.0)
    }

    @objc func hideError() {
        self.titleLabel.textColor = .lisboaGray
        self.editAliasTextField.hideError()
    }
}
