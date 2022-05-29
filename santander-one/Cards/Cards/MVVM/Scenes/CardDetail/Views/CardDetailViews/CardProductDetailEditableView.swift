import Foundation
import UI
import UIKit
import CoreFoundationLib
import OpenCombine

final class CardProductDetailEditableView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var valueLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var editImageView: UIImageView!
    @IBOutlet private weak var editAliasTextField: LisboaTextFieldWithErrorView!
    @IBOutlet private weak var editAliasHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var editAliasOkButton: UIButton!
    private var textField: LisboaTextField { return editAliasTextField.textField }
    private var aliasTextFieldSize: Int = 20
    private var regExValidatorString: CharacterSet?
    private let errorMessageKey = "cardDetail_label_aliasError"
    let onTouchAliasSubject = PassthroughSubject<String, Never>()
    private var card: CardDetail?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configure(card: CardDetail, title: CardDetailTitle, type: CardDetailDataType) {
        self.card = card
        self.titleLabel?.text = title.title
        self.valueLabel.text = title.value
        self.setAccessibilityIdentifiers(type: type)
    }
}

private extension CardProductDetailEditableView {
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
        self.tapEditImage()
        self.setAccessibilityLabels()
        self.imageEditTapped()
    }
    
    func setAccessibilityIdentifiers(type: CardDetailDataType) {
        self.view?.accessibilityIdentifier = AccessibilityCardDetail.cardDetailListItem + "_\(type)"
        self.titleLabel.accessibilityIdentifier = AccessibilityCardDetail.cardDetailEditableItemTitle + "_\(type)"
        self.valueLabel.accessibilityIdentifier = AccessibilityCardDetail.cardDetailEditableItemDescription + "_\(type)"
        self.editImageView.accessibilityIdentifier = AccessibilityCardDetail.btnChange
        self.editAliasTextField.accessibilityIdentifier = AccessibilityCardDetail.cardDetailEditableItem + "_\(type)"
        self.textField.accessibilityIdentifier = AccessibilityCardDetail.cardDetailEditableTextField
        self.editAliasOkButton.accessibilityIdentifier = AccessibilityCardDetail.cardDetailEditableItemOKButton
    }
    
    func setAccessibilityLabels() {
        self.editImageView.accessibilityLabel = localized(AccessibilityCardDetail.buttonChangeAlias)
    }
    
    // MARK: - UI Setup
    func setupDetailEditableView() {
        self.setupTextField()
        self.setupRightButton()
    }
    
    func setupTextField() {
        let textFieldFormmater = UIFormattedCustomTextField()
        textFieldFormmater.setAllowOnlyCharacters(.alias)
        textFieldFormmater.setMaxLength(maxLength: self.aliasTextFieldSize)
        if let regExValidatorString = regExValidatorString {
            textFieldFormmater.setAllowOnlyCharacters(regExValidatorString)
        } else {
            textFieldFormmater.setAllowOnlyCharacters(.alias)
        }
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
        editAliasOkButton.backgroundColor = .darkTorquoise
        editAliasOkButton.layer.cornerRadius = 6.0
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.santander(family: .text, type: .bold, size: 14), .foregroundColor: UIColor.white]
        let attributedText = NSAttributedString(string: localized("generic_link_ok"), attributes: attributes)
        editAliasOkButton.setAttributedTitle(attributedText, for: .normal)
        editAliasOkButton.addTarget(self, action: #selector(self.didTouchSaveAliasButton), for: .touchUpInside)
        editAliasTextField.bringSubviewToFront(editAliasOkButton)
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
        if alias.count > self.aliasTextFieldSize || alias.isBlank {
            self.showError(self.errorMessageKey)
            return false
        } else {
            self.hideError()
            return true
        }
    }
    
    // MARK: - Actions
    func tapEditImage() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doEdit(tapGestureRecognizer:)))
        self.editImageView.isUserInteractionEnabled = true
        self.editImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didTapEdit(tapGestureRecognizer: UITapGestureRecognizer) {
        guard self.card?.isChangeAliasEnabled ?? true else {
            Toast.show(localized("generic_alert_notAvailableOperation"))
            return
        }
        if let regExValidatorString = self.card?.regExValidatorString {
            self.regExValidatorString = regExValidatorString
        }
        if let maxAliasLength = self.card?.maxAliasLength {
            self.aliasTextFieldSize = maxAliasLength
        }
        self.onTouchAliasSubject.send("")
        self.hideEditAliasTextField(false)
        self.hideError()
        self.textField.setTextFieldFocus()
    }
    
    @objc func didTouchSaveAliasButton() {
        guard let newAlias = self.textField.text else { return }
        if self.isAliasCorrect(newAlias) {
            self.onTouchAliasSubject.send(newAlias)
            self.hideEditAliasTextField(true)
            self.valueLabel.text = newAlias
        } else {
            self.showError(self.errorMessageKey)
        }
        self.hideKeyboard()
    }
    
    // TODO: delete legacy code
    
    @objc func doEdit(tapGestureRecognizer: UITapGestureRecognizer) {
        guard self.card?.isChangeAliasEnabled ?? true else {
            Toast.show(localized("generic_alert_notAvailableOperation"))
            return
        }
        if let regExValidatorString = self.card?.regExValidatorString {
            self.regExValidatorString = regExValidatorString
        }
        if let maxAliasLength = self.card?.maxAliasLength {
            self.aliasTextFieldSize = maxAliasLength
        }
        self.hideEditAliasTextField(false)
        self.hideError()
        self.textField.setTextFieldFocus()
    }
    
    func imageEditTapped() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doEdit(tapGestureRecognizer:)))
        self.editImageView.isUserInteractionEnabled = true
        self.editImageView.addGestureRecognizer(tapGestureRecognizer)
    }
}

extension CardProductDetailEditableView {
    var identifier: String {
        return "ALIAS"
    }
    
    // MARK: - Error View
    func showError(_ error: String?) {
        self.titleLabel.textColor = UIColor.bostonRed
        self.editAliasTextField.showError(error ?? "")
        self.setUpLisboaTextFieldHeight(60.0)
    }

    @objc func hideError() {
        self.titleLabel.textColor = .lisboaGray
        self.editAliasTextField.hideError()
    }
}
