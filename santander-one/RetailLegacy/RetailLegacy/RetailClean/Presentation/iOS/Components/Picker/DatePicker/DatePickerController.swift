import UIKit

protocol DatePickerControllerConfiguration {
    var date: Date? { get }
    var lowerLimitDate: Date? { get }
    var upperLimitDate: Date? { get }
}

protocol DatePickerControllerDelegate: class {
    func valueChanged(date: Date, forTextField textField: UITextField)
}

class DatePickerController: NSObject {
    var selectedValue: Date {
        didSet {
            delegate?.valueChanged(date: selectedValue, forTextField: inputView)
        }
    }
    weak var delegate: DatePickerControllerDelegate?
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        datePicker.locale = Locale(identifier: Locale.preferredLanguages.first ?? "es_ES")
        return datePicker
    }()
    
    var inputView: UITextField
    
    required init(configuration: DatePickerControllerConfiguration, inputView: UITextField, delegate: DatePickerControllerDelegate) {
        selectedValue = configuration.date ?? Date()
        self.inputView = inputView
        self.delegate = delegate
        super.init()
        
        inputView.inputView = datePicker
        inputView.tintColor = .clear
        datePicker.date = selectedValue
        datePicker.timeZone = TimeZone(abbreviation: "UTC")
        datePicker.minimumDate = configuration.lowerLimitDate
        datePicker.maximumDate = configuration.upperLimitDate
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidAppear(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    func updateConfiguration(_ configuration: DatePickerControllerConfiguration) {
        datePicker.minimumDate = configuration.lowerLimitDate
        datePicker.maximumDate = configuration.upperLimitDate
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    private func valueChanged(_ datePicker: UIDatePicker) {
        selectedValue = datePicker.date
    }
    
    @objc
    private func keyboardDidAppear(notification: Notification) {
        if inputView.isFirstResponder {
            selectedValue = datePicker.date
        }
    }
}
