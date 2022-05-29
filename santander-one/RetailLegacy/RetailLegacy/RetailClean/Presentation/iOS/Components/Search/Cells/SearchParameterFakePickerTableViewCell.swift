import UIKit
import UI

class SearchParameterFakePickerTableViewCell: BaseViewCell, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var textFieldTapped: (() -> Void)?
    
    func title(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    
    func selectedOption(_ description: String?) {
        textField.text = description
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 14.0)))
        textField.applyStyle(TextFieldStylist(textColor: .sanGreyDark, font: .latoRegular(size: 18.0), textAlignment: .left))
        textField.delegate = self
        
        textField.rightViewMode = .always
        let image = UIImageView(image: Assets.image(named: "icnArrowDownRed"))
        image.contentMode = .scaleAspectFit
        image.frame = CGRect(x: 0.0, y: 0.0, width: image.bounds.size.width + 20, height: image.bounds.size.height)
        textField.rightView = image
    }
 
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textFieldTapped?()
        return false
    }
}
