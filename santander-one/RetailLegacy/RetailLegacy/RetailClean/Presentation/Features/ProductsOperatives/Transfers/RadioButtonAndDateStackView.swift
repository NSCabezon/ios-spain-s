import UIKit
import UI

class RadioButtonAndDateStackView: RadioButtonStackView {
    lazy var udpateDate: ((String?) -> Void) = { [weak self] value in
        self?.date = value
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var dateTextField: NotCopyPasteTextField! {
        didSet {
            (dateTextField as UITextField).applyStyle(TextFieldStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16.0), textAlignment: .left))
            textFieldObservation = dateTextField.observe(\NotCopyPasteTextField.text) { [weak self] _, _ in
                self?.textFieldChanged()
            }
            dateTextField.adjustsFontSizeToFitWidth = true
            dateTextField.minimumFontSize = 11.0
            setRightView()
        }
    }
    
    // MARK: - Private attributes
    
    private lazy var calendarView: UIView = {
        let image = Assets.image(named: "icnCalendar") ?? UIImage()
        let imageView = UIImageView(image: image)
        let padding: CGFloat = 10.0
        let container = UIView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: image.size.width + padding * 2.0,
                                             height: image.size.height + padding * 2.0))
        container.addSubview(imageView)
        container.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(RadioButtonAndDateStackView.didClickCalendarView))
        container.addGestureRecognizer(tap)
        
        imageView.frame.move(to: CGPoint(x: padding, y: padding))
        
        return container
    }()
    
    private var textFieldObservation: NSKeyValueObservation?
    
    deinit {
        textFieldObservation?.invalidate()
    }
    
    // MARK: - Public attributes
    
    var date: String? {
        get {
            return dateTextField.text
        }
        set {
            dateTextField.text = newValue
            setRightView()
        }
    }
    
    var newDateValue: ((_ value: String?) -> Void)?
    
    // MARK: - Private methods
    
    override func updateMarked() {
        dateTextField.isHidden = !isChecked
        super.updateMarked()
    }
    
    private func setRightView() {
        dateTextField.rightView = calendarView
        dateTextField.rightViewMode = .always
        dateTextField.clearButtonMode = .never
    }
    
    @objc private func didClickCalendarView() {
        dateTextField.becomeFirstResponder()
    }
    
    private func textFieldChanged() {
        newDateValue?(dateTextField.text)
    }
    
}

extension RadioButtonAndDateStackView: DatePickerCell {
    
    var dateField: UITextField {
        return dateTextField
    }
}
