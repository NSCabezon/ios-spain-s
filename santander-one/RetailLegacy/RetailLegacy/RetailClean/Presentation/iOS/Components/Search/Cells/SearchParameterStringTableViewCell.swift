import UIKit

class SearchParameterStringTableViewCell: BaseViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var inputTextField: KeyboardTextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    var textFieldDidChange: ((String?) -> Void)?
    var searchPressed: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: UIFont.latoBold(size: 16.0), textAlignment: .left))
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: UIFont.latoItalic(size: 14.0), textAlignment: .left))
        (inputTextField as UITextField).applyStyle(TextFieldStylist(textColor: .sanGreyDark, font: UIFont.latoRegular(size: 15), textAlignment: .left))
        searchButton.applyStyle(ButtonStylist(textColor: .uiWhite, font: UIFont.latoMedium(size: 16.0)))
        backgroundColor = UIColor.clear
        separatorView.backgroundColor = .lisboaGray
        inputTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        inputTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingDidEnd)
        searchButton.addTarget(self, action: #selector(searchPressed(_:)), for: .touchUpInside)
        inputTextField.reponderOrder = .subview
    }
    
    func title(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    
    func subTitle(_ title: LocalizedStylableText) {
        subtitleLabel.set(localizedStylableText: title)
    }
    
    func searchButtonTitle(_ title: LocalizedStylableText) {
        searchButton.set(localizedStylableText: title, state: .normal)
    }
    
    var inputString: String? {
        get {
            return inputTextField.text
        }
        set {
            inputTextField.text = newValue
        }
    }
    
    @objc func textFieldChanged(_ textField: UITextField) {
        textFieldDidChange?(textField.text)
    }
    
    @objc func searchPressed(_ sender: UIButton) {
        searchPressed?()
    }
}
