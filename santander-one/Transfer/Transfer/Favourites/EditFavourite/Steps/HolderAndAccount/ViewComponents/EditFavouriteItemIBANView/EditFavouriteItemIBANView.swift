//
//  EditFavouriteItemIBANView.swift
//  Transfer-Transfer
//
//  Created by Luis Escámez Sánchez on 19/8/21.
//

import UIKit
import UI
import Operative
import CoreFoundationLib

protocol EditFavouriteItemIBANViewDelegate: AnyObject {
    func ibanDidBeginEditing()
}

final class EditFavouriteItemIBANView: XibView {
    
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet weak var textFieldStackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet private(set) weak var ibanLisboaTextField: IBANLisboaTextField! {
        didSet {
            ibanLisboaTextField.field.addTarget(self, action: #selector(hideError), for: .editingChanged)
            ibanLisboaTextField.field.addTarget(self, action: #selector(ibanDidBeginEditing), for: .editingDidBegin)
        }
    }
    @IBOutlet weak var errorLabel: UILabel!
    private weak var delegate: EditFavouriteItemIBANViewDelegate?
    weak var updatableDelegate: UpdatableTextFieldDelegate? {
        didSet {
            self.ibanLisboaTextField.updatableDelegate = updatableDelegate
        }
    }
    var validatableTextField: ValidatableField {
        return self.ibanLisboaTextField
    }
    
    var text: String? {
        return self.ibanLisboaTextField.countryAndCheckDigit + (ibanLisboaTextField.text ?? "")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setInfo(_ viewModel: EditFavouriteItemViewModel, bankUtils: BankingUtilsProtocol) {
        self.titleLabel.text = viewModel.title
        self.ibanLisboaTextField.setBankingUtils(bankUtils)
        self.ibanLisboaTextField.copyText(text: viewModel.description ?? "")
        self.accessibilityIdentifier = viewModel.accesibilityIdentificator
        self.ibanLisboaTextField.fixedControlDigit = bankUtils.textInputAttributes.checkDigit
    }
    
    func configureIBANTextfieldAppearance(showFloatingTitle: Bool) {
        self.ibanLisboaTextField.setIsNeededFloatingTitle(showFloatingTitle)
    }
    
    func setDelegates(delegate: EditFavouriteItemIBANViewDelegate, updatableDelegate: UpdatableTextFieldDelegate) {
        self.delegate = delegate
        self.updatableDelegate = updatableDelegate
    }
    
    func showError(_ key: String) {
        self.contentViewHeightConstraint.constant += 19
        self.errorLabel.isHidden = false
        self.errorLabel.text = localized(key)
        self.titleLabel.textColor = .bostonRed
        self.ibanLisboaTextField.setErrorAppearance()
        self.superview?.setNeedsUpdateConstraints()
    }
}

private extension EditFavouriteItemIBANView {
    
    func setAppearance() {
        self.ibanLisboaTextField.accessibilityIdentifier = AccessibilityOthers.areaInputText.rawValue
        self.ibanLisboaTextField.configure(with: nil, title: localized("sendMoney_label_iban"), extraInfo: nil, disabledActions: [.copy, .cut])
        self.errorLabel.setSantanderTextFont(type: .regular, size: 12, color: .bostonRed)
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.font = .santander(family: .text, type: .light, size: 16.0)
        self.separatorView.backgroundColor = .mediumSkyGray
    }
    
    @objc func hideError() {
        guard !self.errorLabel.isHidden else { return }
        self.titleLabel.textColor = .lisboaGray
        self.contentViewHeightConstraint.constant = 97
        self.errorLabel.isHidden = true
        self.ibanLisboaTextField.clearErrorAppearanceWithFieldVisible()
    }
    
    @objc func ibanDidBeginEditing() {
        self.delegate?.ibanDidBeginEditing()
    }
}
