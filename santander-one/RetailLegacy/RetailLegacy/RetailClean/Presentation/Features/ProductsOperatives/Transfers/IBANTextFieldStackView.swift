import UIKit
import CoreFoundationLib

class IBANTextFieldStackView: StackItemView, ChangeTextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var ibanTextField: IBANTextField! {
        didSet {
            ibanTextField.applyStyle(TextFieldStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16.0), textAlignment: .left))
        }
    }
    
    // MARK: - Public attributes
    
    var styledPlaceholder: LocalizedStylableText? {
        didSet {
            let attrs = [NSAttributedString.Key.font: UIFont.latoItalic(size: 16.0), .foregroundColor: UIColor.sanGreyMedium]
            ibanTextField.setOnPlaceholder(localizedStylableText: styledPlaceholder ?? .empty,
                                           attributes: attrs)
        }
    }
    
    var info: IBANTextFieldInfo? {
        get {
            return ibanTextField.info
        }
        set {
            ibanTextField.info = newValue
        }
    }
    
    var newTextFieldValue: ((_ value: String?) -> Void)?
    
    var bankingUtils: BankingUtilsProtocol? {
        didSet {
            if let bankingUtils = bankingUtils {
                ibanTextField.setBankingUtils(bankingUtils)
            }
        }
    }
    
    // MARK: - Public methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ibanTextField.customDelegate = self
        backgroundColor = .clear
    }
    
    lazy var setTextFieldValue: ((String) -> Void) = { [weak self] value in
        self?.ibanTextField.copyText(text: value)
        self?.newTextFieldValue?(self?.ibanTextField.text)
    }
    
    // MARK: - ChangeTextFieldDelegate
    
    func willChangeText(textField: UITextField, text: String) {
        let countryCodeWithCheckDigit = (textField as? IBANTextField)?.ccWithCheckDigit ?? ""
        newTextFieldValue?(countryCodeWithCheckDigit + text)
    }

}
