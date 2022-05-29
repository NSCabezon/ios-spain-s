//

import UIKit

class ConfirmationTextFieldTableViewCell: BaseViewCell, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var textField: KeyboardTextField! {
        didSet {
            (textField as UITextField).applyStyle(TextFieldStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16.0), textAlignment: .left))
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoSemibold(size: 16)))
        }
    }
    
    @IBOutlet private weak var containerView: UIView!
    
    // MARK: - Public attributes
    
    var styledPlaceholder: LocalizedStylableText? {
        didSet {
            textField.setOnPlaceholder(localizedStylableText: styledPlaceholder ?? .empty)
        }
    }
    
    func setText(text: String?) {
        textField.text = text
    }
    
    func setTitle(title: LocalizedStylableText?) {
        guard let title = title else {
            titleLabel.isHidden = true
            return
        }
        titleLabel.set(localizedStylableText: title)
        titleLabel.isHidden = false
    }
    
    var newTextFieldValue: ((_ value: String?) -> Void)?
    
    // MARK: - Public methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        StylizerPGViewCells.applyMiddleViewCellStyle(view: containerView)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let util = (textField.text ?? "") as NSString
        let text = util.replacingCharacters(in: range, with: string) as String
        newTextFieldValue?(text)
        return true
    }
}
