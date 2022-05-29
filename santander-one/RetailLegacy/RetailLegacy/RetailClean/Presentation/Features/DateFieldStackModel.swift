import UIKit

protocol DateFieldStackModelDelegate: class {
    func dateChanged(inputIdentifier: String, date: Date?)
}

class DateFieldStackModel: StackItem<DateFieldStackView>, DatePickerControllerConfiguration {
    var lowerLimitDate: Date? {
        didSet {
            pickerController?.updateConfiguration(self)
        }
    }
    var upperLimitDate: Date? {
        didSet {
            pickerController?.updateConfiguration(self)
        }
    }
    var date: Date?
    weak var delegate: DateFieldStackModelDelegate?
    private let placeholder: LocalizedStylableText
    private let textFieldStyle: TextFieldStylist
    private let dependencies: PresentationComponent
    private weak var viewRef: DateFieldStackView?
    private var pickerController: DatePickerController?
    private var inputIdentifier: String
    
    init(inputIdentifier: String, placeholder: LocalizedStylableText, date: Date?, textFieldStyle: TextFieldStylist, privateComponent: PresentationComponent, insets: Insets = Insets(left: 10, right: 10, top: 0, bottom: 24)) {
        self.inputIdentifier = inputIdentifier
        self.placeholder = placeholder
        self.date = date
        self.textFieldStyle = textFieldStyle
        self.dependencies = privateComponent
        super.init(insets: insets)
    }
    
    override func bind(view: DateFieldStackView) {
        pickerController = DatePickerController(configuration: self, inputView: view.textField, delegate: self)
        viewRef = view
        (view.textField as UITextField).applyStyle(textFieldStyle)
        view.textCleared = { [weak self] in
            self?.date = nil
            self?.delegate?.dateChanged(inputIdentifier: self?.inputIdentifier ?? "", date: self?.date)
        }
        view.newDateValue = { [weak self] date in
            self?.date = self?.dependencies.timeManager.fromString(input: date, inputFormat: .d_MMM_yyyy)
            self?.delegate?.dateChanged(inputIdentifier: self?.inputIdentifier ?? "", date: self?.date)
        }
        if let date = date {
            view.date = formatDate(date: date)
        } else {
            view.styledPlaceholder = placeholder
        }
    }
}

extension DateFieldStackModel: DateSelectionViewModel {
    func formatDate(date: Date) -> String {
        return dependencies.timeManager.toString(date: date, outputFormat: .d_MMM_yyyy, timeZone: .local) ?? ""
    }
}

extension DateFieldStackModel: DatePickerControllerDelegate {
    func valueChanged(date: Date, forTextField textField: UITextField) {
        viewRef?.textField.text = formatDate(date: date)
    }
}
