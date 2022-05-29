import UIKit

class RadioButtonAndDateStackModel: RadioButtonStackModel<RadioButtonAndDateStackView>, DatePickerControllerConfiguration {
    var date: Date?
    var lowerLimitDate: Date?
    var upperLimitDate: Date?
    var dependencies: PresentationComponent
    weak var delegate: DateFieldStackModelDelegate?
    private weak var viewRef: RadioButtonAndDateStackView?
    private var pickerController: DatePickerController?
    private var inputIdentifier: String
    private var udpateDate: ((String?) -> Void)?

    init(inputIdentifier: String, title: LocalizedStylableText, isSelected selected: Bool, insets: Insets = Insets(left: 11, right: 10, top: 15, bottom: 6), dependencies: PresentationComponent) {
        self.dependencies = dependencies
        self.inputIdentifier = inputIdentifier
        super.init(title: title, isSelected: selected, insets: insets)
    }
    
    override func bind(view: RadioButtonAndDateStackView) {
        super.bind(view: view)
        pickerController = DatePickerController(configuration: self, inputView: view.dateTextField, delegate: self)
        viewRef = view
        if let date = date {
            view.date = formatDate(date: date)
        }
        view.newDateValue = { [weak self] newDate in
            self?.date = self?.dependencies.timeManager.fromString(input: newDate, inputFormat: .d_MMM_yyyy)
            self?.delegate?.dateChanged(inputIdentifier: self?.inputIdentifier ?? "", date: self?.date)
        }
        udpateDate = view.udpateDate
    }
    
    func setDate(date: Date) {
        udpateDate?(formatDate(date: date))
        pickerController?.datePicker.date = date
        pickerController?.datePicker.minimumDate = lowerLimitDate
        pickerController?.datePicker.maximumDate = upperLimitDate
        pickerController?.datePicker.reloadInputViews()
    }
}

extension RadioButtonAndDateStackModel: DateSelectionViewModel {
    func formatDate(date: Date) -> String {
        return dependencies.timeManager.toString(date: date, outputFormat: .d_MMM_yyyy) ?? ""
    }
}

extension RadioButtonAndDateStackModel: DatePickerControllerDelegate {
    func valueChanged(date: Date, forTextField textField: UITextField) {
        viewRef?.dateTextField.text = formatDate(date: date)
    }
}
