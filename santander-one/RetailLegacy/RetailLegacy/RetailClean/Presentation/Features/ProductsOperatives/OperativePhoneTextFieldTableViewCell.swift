//
import UIKit

class OperativePhoneTextFieldTableViewCell: BaseViewCell {

    var phone: String? {
        didSet {
            guard let phone = phone else { return }
            textView.textColor = .sanRed
            textView.font = .latoLight(size: 22)
            textView.text = phone
        }
    }
    
    var placeholder: LocalizedStylableText? {
        didSet {
            guard let placeholder = placeholder else { return }
            textView.text = placeholder.text
        }
    }
    
    @IBOutlet weak var textView: PhoneTextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.textColor = .sanGreyMedium
        textView.font = .latoItalic(size: 14)
        textView.autocorrectionType = .no
        
        backgroundColor = .clear
        selectionStyle = .none
    }
}
