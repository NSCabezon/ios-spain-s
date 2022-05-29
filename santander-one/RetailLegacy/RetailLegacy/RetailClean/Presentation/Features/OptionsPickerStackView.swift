import UIKit
import UI

class OptionsPickerStackView: StackItemView {
    @IBOutlet weak var textField: NotCopyPasteTextField! {
        didSet {
            setRightView()
            (textField as UITextField).applyStyle(TextFieldStylist(textColor: .sanGreyDark, font: UIFont.latoSemibold(size: 16), textAlignment: .left))
            textField.tintColor = .clear
        }
    }
    
    private var pickerDelegateAndDataSource: OptionsPickerDelegateAndDataSource?
    
    func setPickerDelegateAndDataSource(_ delegate: OptionsPickerDelegateAndDataSource, selectedRow: Int = 0, component: Int = 0, animated: Bool = false) {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        pickerDelegateAndDataSource = delegate
        picker.delegate = delegate
        picker.dataSource = delegate
        textField.inputView = picker
        picker.selectRow(selectedRow, inComponent: component, animated: animated)
    }
    
    private func setRightView() {
        guard let image = Assets.image(named: "icnArrowDownRed") else { return }
        let imageView = UIImageView(image: image)
        let padding: CGFloat = 15.0
        let container = UIView(frame: CGRect(x: 0, y: 0, width: image.size.width + padding * 2.0, height: image.size.height + padding * 2.0))
        container.addSubview(imageView)
        container.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didClickPickerView))
        container.addGestureRecognizer(tap)
        imageView.frame.move(to: CGPoint(x: padding, y: padding))
        textField.rightView = container
        textField.rightViewMode = .always
        textField.clearButtonMode = .never
    }
    
    @objc private func didClickPickerView() {
        textField.becomeFirstResponder()
    }
    
    // MARK: - Overrided methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
}
