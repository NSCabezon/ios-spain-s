import UIKit

protocol TextFieldTableViewCellDelegate: class {
    
}

class TextFieldTableViewCell: BaseViewCell {
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tralingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var styledPlaceholder: LocalizedStylableText? {
        didSet {
            let attrs = [NSAttributedString.Key.font: UIFont.latoItalic(size: 16.0), .foregroundColor: UIColor.sanGreyMedium]
            textField.setOnPlaceholder(localizedStylableText: styledPlaceholder ?? .empty,
                                       attributes: attrs)
        }
    }
    
    func setText(text: String?) {
        textField.text = text
    }
    
    var newTextFieldValue: ((_ value: String?) -> Void)?
    
    @IBOutlet weak var textField: CustomTextField! {
        didSet {
            textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
            textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingDidEnd)
            (textField as UITextField).applyStyle(TextFieldStylist(textColor: .sanGreyDark, font: .latoRegular(size: 15.0), textAlignment: .left))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    @objc
    func textFieldChanged(_ textField: UITextField) {
        newTextFieldValue?(textField.text)
    }
    
    func setInstes(insets: Insets?) {
        if let insets = insets {
            leadingConstraint.constant = CGFloat(insets.left)
            tralingConstraint.constant = CGFloat(insets.right)
            topConstraint.constant = CGFloat(insets.top)
            bottomConstraint.constant = CGFloat(insets.bottom)
        }
    }
}
