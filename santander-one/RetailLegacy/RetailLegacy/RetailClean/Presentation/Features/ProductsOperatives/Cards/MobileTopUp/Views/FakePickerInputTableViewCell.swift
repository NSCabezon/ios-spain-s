import UIKit
import UI

class FakePickerInputTableViewCell: BaseViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var optionTextField: UITextField!
    
    var pickerText: String? {
        set {
            optionTextField.text = newValue
        }
        get {
            return optionTextField.text
        }
    }
    
    func setTitle(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .uiBackground
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark,
                                           font: UIFont.latoBold(size: 16),
                                           textAlignment: .left))
        optionTextField.rightViewMode = .always
        let image = UIImageView(image: Assets.image(named: "icnArrowDownRed"))
        image.contentMode = .scaleAspectFit
        image.frame = CGRect(x: 0.0, y: 0.0, width: image.bounds.size.width + 20, height: image.bounds.size.height)
        optionTextField.rightView = image
    }
    
}
