//

import UIKit

class ChangeAliasTableViewCell: BaseViewCell {
    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var aliasTextField: CustomTextField!
    @IBOutlet weak var saveButton: WhiteButton!
    @IBOutlet weak var bottomSeparator: UIView!
    weak var editDelegate: ProductDetailInfoDataSourceDelegate?
    
    var infoTitle: LocalizedStylableText? {
        didSet {
            guard let title = infoTitle else { return }
            titleLabel.set(localizedStylableText: title)
        }
    }
    
    var infoTextField: String? {
        didSet {
            guard let info = infoTextField else { return }
            aliasTextField.text = info
        }
    }
    
    var infoSaveButton: LocalizedStylableText? {
        didSet {
            guard let titleSaveButton = infoSaveButton else { return }
            saveButton.set(localizedStylableText: titleSaveButton, state: .normal)
        }
    }
    
    var maxLength: Int? {
        didSet {
            aliasTextField.formattedDelegate.maxLength = maxLength
        }
    }
    
    var characterSet: CharacterSet? {
        didSet {
            guard let charSet = characterSet else { return }
            aliasTextField.formattedDelegate.characterSet = charSet
        }
    }
    
    var customDelegate: ChangeTextFieldDelegate? {
        didSet {
            aliasTextField.customDelegate = customDelegate
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        topSeparator.backgroundColor = .lisboaGray
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: UIFont.latoRegular(size: 16), textAlignment: .left))
        (aliasTextField as UITextField).applyStyle(TextFieldStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: 18), textAlignment: .left))
        saveButton.configureHighlighted(font: UIFont.latoSemibold(size: 13))
        bottomSeparator.backgroundColor = .lisboaGray
    }
    
    @IBAction func editSaved(_ sender: Any) {
        editDelegate?.endEditing(withNewAlias: aliasTextField.text)
    }
}
