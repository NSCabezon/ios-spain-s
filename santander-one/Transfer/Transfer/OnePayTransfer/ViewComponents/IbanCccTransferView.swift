//
//  IbanCccTransferView.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 27/05/2020.
//

import UI
import CoreFoundationLib

protocol IbanCccTransferViewDelegate: AnyObject {
    func ibanDidBeginEditing()
}

public protocol IbanCccTransferControlDigitDelegate: AnyObject {
    func controlDigitFrom(_ countryCode: String) -> String?
}

final class IbanCccTransferView: UIDesignableView {
    @IBOutlet weak var errorIbanView: UIView! {
        didSet {
            self.errorIbanView.isHidden = true
        }
    }
    @IBOutlet weak var errorIbanLabel: UILabel! {
        didSet {
            self.errorIbanLabel.setSantanderTextFont(type: .regular, size: 13, color: .bostonRed)
        }
    }
    @IBOutlet private(set) weak var ibanLisboaTextField: IBANLisboaTextField! {
        didSet {
            ibanLisboaTextField.field.addTarget(self, action: #selector(hideError), for: .editingChanged)
            ibanLisboaTextField.field.addTarget(self, action: #selector(ibanDidBeginEditing), for: .editingDidBegin)
        }
    }
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    weak var updatableDelegate: UpdatableTextFieldDelegate? {
        didSet {
            self.ibanLisboaTextField.updatableDelegate = updatableDelegate
        }
    }
    
    public weak var delegate: IbanCccTransferViewDelegate?
    public weak var controlDigitDelegate: IbanCccTransferControlDigitDelegate?
    
    @IBOutlet weak var tooltipButton: UIButton!
    
    override func getBundleName() -> String {
        return "Transfer"
    }
    
    override func commonInit() {
        super.commonInit()
        configureView()
    }
    
    var text: String? {
        return ibanLisboaTextField.countryAndCheckDigit + (ibanLisboaTextField.text ?? "")
    }
    
    func setText(_ text: String) {
        ibanLisboaTextField.copyText(text: text)
    }
    
    func setBankingUtil(_ bankingUtils: BankingUtilsProtocol, controlDigitDelegate: IbanCccTransferControlDigitDelegate?) {
        self.controlDigitDelegate = controlDigitDelegate
        ibanLisboaTextField.fixedControlDigit = self.controlDigitDelegate?.controlDigitFrom(bankingUtils.countryCode ?? "")
        ibanLisboaTextField.setBankingUtils(bankingUtils)
    }

    func showError(_ errorKey: String) {
        self.errorIbanView.isHidden = false
        self.errorIbanLabel.text = localized(errorKey).text
        self.errorIbanLabel.accessibilityIdentifier = errorKey
        self.ibanLisboaTextField.setErrorAppearance()
    }

    @objc func hideError() {
        guard !errorIbanView.isHidden else { return }
        self.errorIbanView.isHidden = true
        self.ibanLisboaTextField.clearErrorAppearanceWithFieldVisible()
    }
    
    @objc func ibanDidBeginEditing() {
        self.delegate?.ibanDidBeginEditing()
    }
    
    @IBAction func showTooltip(_ sender: Any) {
        
        guard let associated = tooltipButton else { return }
        BubbleLabelView.startWith(associated: associated, localizedStyleText: localized("sendMoney_tooltip_whatIban"), position: .automatic)
    }
    
    func hideTooltip() {
        self.tooltipButton.isHidden = true
    }
    
    func adjustSideMargins() {
        self.trailingConstraint.constant = 0.0
        self.leadingConstraint.constant = 0.0
    }
}

private extension IbanCccTransferView {
    func configureView() {
        ibanLisboaTextField.configure(with: nil, title: localized("sendMoney_label_iban"), extraInfo: nil, disabledActions: [.copy, .cut])
        ibanLisboaTextField.titleLabel.accessibilityIdentifier = AccessibilityOthers.areaInputText.rawValue
        tooltipButton.setTitle(localized("sendMoney_label_whatIban"), for: .normal)
        tooltipButton.accessibilityIdentifier = AccessibilityOthers.whatIBAN.rawValue
        tooltipButton.titleLabel?.font = .santander(size: 12)
        tooltipButton.tintColor = UIColor.darkTorquoise
    }
}
