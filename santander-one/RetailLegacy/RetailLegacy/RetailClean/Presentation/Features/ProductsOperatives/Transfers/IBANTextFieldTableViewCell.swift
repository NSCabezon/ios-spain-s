//

import UIKit
import CoreFoundationLib

protocol PrefixCalculationDelegate: class {
    func ibanPrefixUpdated(updatedPrefix: String)
}

class IBANTextFieldTableViewCell: BaseViewCell, ChangeTextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var ibanTextField: IBANTextField! {
        didSet {
            ibanTextField.applyStyle(TextFieldStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16.0), textAlignment: .left))
            ibanTextField.prefixDelegate = self
        }
    }
    
    weak var prefixCalculationDelegate: PrefixCalculationDelegate?
    
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
    
    var bankingUtils: BankingUtilsProtocol? {
        didSet {
            if let bankingUtils = self.bankingUtils {
                ibanTextField.setBankingUtils(bankingUtils)
            }
        }
    }
    
    var newTextFieldValue: ((_ value: String?) -> Void)?
    
    // MARK: - Public methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ibanTextField.customDelegate = self
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    // MARK: - ChangeTextFieldDelegate
    
    func willChangeText(textField: UITextField, text: String) {
        newTextFieldValue?(text)
    }

}

extension IBANTextFieldTableViewCell: IbanPrefixDelegate {
    func updateWithCalculatedPrefix(_ prefix: String) {
        prefixCalculationDelegate?.ibanPrefixUpdated(updatedPrefix: prefix)
    }
}
