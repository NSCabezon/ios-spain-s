//

import UIKit
import UI

class OptionsPickerTableViewCell: BaseViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var textField: NotCopyPasteTextField! {
        didSet {
            setRightView()
            textField.tintColor = .clear
        }
    }
    
    var pickerDelegateAndDataSource: OptionsPickerDelegateAndDataSource? {
        didSet {
            let picker = UIPickerView()
            picker.translatesAutoresizingMaskIntoConstraints = false
            picker.delegate = pickerDelegateAndDataSource
            picker.dataSource = pickerDelegateAndDataSource
            textField.inputView = picker
        }
    }
    
    private func setRightView() {
        let image = Assets.image(named: "icnArrowDownRed") ?? UIImage()
        let imageView = UIImageView(image: image)
        let padding: CGFloat = 15.0
        let container = UIView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: image.size.width + padding * 2.0,
                                             height: image.size.height + padding * 2.0))
        container.addSubview(imageView)
        container.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(OptionsPickerTableViewCell.didClickPickerView))
        container.addGestureRecognizer(tap)
        imageView.frame.move(to: CGPoint(x: padding, y: padding))
        
        textField.rightView = container
        textField.rightViewMode = .always
        textField.clearButtonMode = .never
    }
    
    @objc private func didClickPickerView() {
        textField.becomeFirstResponder()
    }
    
    func setSelected(option: String, position: Int) {
        let picker = textField.inputView as? UIPickerView
        picker?.selectRow(position, inComponent: 0, animated: false)
    }
    
    func setIdentifier(_ cellIdentifier: String?) {
        textField.accessibilityIdentifier = cellIdentifier
    }
    
    // MARK: - Overrided methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    override func configureStyle() {
        super.configureStyle()
        (textField as UITextField).applyStyle(TextFieldStylist(textColor: .sanGreyDark, font: UIFont.latoRegular(size: 16), textAlignment: .left))
    }
}

// MARK: - OptionsPickerDelegateAndDataSource

class OptionsPickerDelegateAndDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let completion: (Int) -> Void
    let options: [String]
    
    init(options: [String], completion: @escaping (Int) -> Void) {
        self.completion = completion
        self.options = options
    }
    
    func numberOfRows(in optionPicker: OptionPickerView) -> Int {
        return options.count
    }
    
    func optionPicker(_ optionPicker: OptionPickerView, titleFor row: Int) -> String {
        return options[row]
    }
    
    // MARK: - UIPickerViewDatasource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        completion(row)
    }
}
