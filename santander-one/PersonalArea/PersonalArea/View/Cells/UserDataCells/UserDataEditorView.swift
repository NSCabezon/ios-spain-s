//
//  UserDataEditorView.swift
//  PersonalArea
//
//  Created by alvola on 15/01/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol UserDataEditorViewDelegate: AnyObject {
    func saveValue(_ value: String)
}

final class UserDataEditorView: DesignableView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueTextField: UITextField!
    @IBOutlet private weak var saveButton: WhiteLisboaButton!
    @IBOutlet private weak var separationView: UIView!
    
    private var allowedCharacters: CharacterSet?
    weak var delegate: UserDataEditorViewDelegate?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func configureWith(_ title: String, _ prevValue: String?, allowedCharacters: CharacterSet?, _ delegate: UserDataEditorViewDelegate?) {
        titleLabel?.text = title
        valueTextField?.text = prevValue
        self.allowedCharacters = allowedCharacters
        self.delegate = delegate
    }
    
    override func becomeFirstResponder() -> Bool {
        return valueTextField?.becomeFirstResponder() ?? false
    }
    
    private func commonInit() {
        configureView()
        configureLabel()
        configureTextField()
        configureButton()
    }
    
    private func configureView() {
        contentView?.backgroundColor = UIColor.skyGray
        contentView?.layer.borderColor = UIColor.mediumSkyGray.cgColor
        contentView?.layer.borderWidth = 1.0
        separationView?.backgroundColor = UIColor.darkTurqLight
    }
    
    private func configureLabel() {
        titleLabel.font = UIFont.santander(family: .text, size: 12.0)
        titleLabel.textColor = UIColor.brownishGray
    }
    
    private func configureTextField() {
        valueTextField.font = UIFont.santander(family: .text, size: 17.0)
        valueTextField.textColor = UIColor.lisboaGray
        valueTextField.delegate = self
        valueTextField.accessibilityIdentifier = "personalDataEditTextAlias"
        valueTextField.autocapitalizationType = .none
        valueTextField.returnKeyType = .done
    }
    
    private func configureButton() {
        saveButton.addSelectorAction(target: self, #selector(saveAction))
        saveButton.backgroundNormalColor = UIColor.clear
        saveButton.accessibilityIdentifier = "btnChange"
        saveButton.titleLabel?.font = .santander(family: .text, type: .regular, size: 12)
        saveButton.setTitle(localized("generic_button_save"), for: .normal)
    }
    
    @objc private func saveAction() {
        contentView?.endEditing(true)
        delegate?.saveValue(valueTextField?.text ?? "")
    }
}

extension UserDataEditorView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentView?.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard evaluateChars(string) else { return false }
        let newString = ((textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? "").uppercased()
        return newString.count <= 20
    }
    
    func evaluateChars(_ string: String) -> Bool {
        guard let characterSet = allowedCharacters else { return true }
        let character = CharacterSet(charactersIn: string)
        return characterSet.isSuperset(of: character)
    }
}
