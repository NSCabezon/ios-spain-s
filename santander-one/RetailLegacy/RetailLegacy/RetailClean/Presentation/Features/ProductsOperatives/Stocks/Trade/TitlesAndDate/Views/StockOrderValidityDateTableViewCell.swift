import UIKit
import UI

class StockOrderValidityDateTableViewCell: BaseViewCell, UITextFieldDelegate {
    
    var date: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
            setRightView()
        }
    }
    
    var styledPlaceholder: LocalizedStylableText? {
        didSet {
            textField.setOnPlaceholder(localizedStylableText: styledPlaceholder ?? .empty)
        }
    }
    
    var newDateValue: ((_ value: String?) -> Void)?
    var textCleared: (() -> Void)?
    
    @IBOutlet weak var textField: NotCopyPasteTextField! {
        didSet {
            textFieldObservation = textField.observe(\NotCopyPasteTextField.text) { [weak self] _, _ in
                self?.textFieldChanged()
            }
            textField.delegate = self
            setRightView()
        }
    }
    
    private var textWillClear: Bool = false
    
    private lazy var calendarView: UIView = {
        let image = Assets.image(named: "icnCalendar") ?? UIImage()
        let imageView = UIImageView(image: image)
        let padding: CGFloat = 15.0
        let container = UIView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: image.size.width + padding * 2.0,
                                             height: image.size.height + padding * 2.0))
        container.addSubview(imageView)
        
        container.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(StockOrderValidityDateTableViewCell.didClickCalendarView))
        container.addGestureRecognizer(tap)
        
        imageView.frame.move(to: CGPoint(x: padding, y: padding))
        
        return container
    }()
    
    @objc func didClickCalendarView() {
        textField.becomeFirstResponder()
    }
    
    private var textFieldObservation: NSKeyValueObservation?
    
    deinit {
        textFieldObservation?.invalidate()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    func textFieldChanged() {
        newDateValue?(textField.text)
        let text = textField.text ?? ""
        if text.isEmpty {
            textWillClear = true
            textCleared?()
            textField.resignFirstResponder()
        }
        dateChanged()
    }
    
    func dateChanged() {
        setRightView()
        textWillClear = false
    }
    
    private func setRightView() {
        textField.rightView = calendarView
        textField.rightViewMode = .always
        textField.clearButtonMode = .never
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            textField.text = nil
        }
        // returns false to avoid keyboard notifications (used by date picker controller)
        return false
    }
}

extension StockOrderValidityDateTableViewCell: DatePickerCell {
    var dateField: UITextField {
        return textField
    }
}
