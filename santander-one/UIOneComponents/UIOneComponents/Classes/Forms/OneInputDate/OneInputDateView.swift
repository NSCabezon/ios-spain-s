//
//  OneInputDateView.swift
//  UIOneComponents
//
//  Created by Daniel Gómez Barroso on 28/9/21.
//

import UI
import CoreFoundationLib
import OpenCombine

public protocol OneInputDateViewDelegate: AnyObject {
    func didSelectNewDate(_ dateValue: Date)
    func didSelectCancelOption()
}

public extension OneInputDateViewDelegate {
    func didSelectCancelOption() {}
}

// Reactive
public protocol ReactiveOneInputDateView {
    var publisher: AnyPublisher<ReactiveOneInputDateViewState, Never> { get }
}
public enum ReactiveOneInputDateViewState: State {
    case didSelectNewDate(_ dateValue: Date)
}

public final class OneInputDateView: XibView {
    private struct Constants {
        static let datePickerWidth: CGFloat = UIScreen.main.bounds.width
        static var datePickerHeight: CGFloat = 216
    }

    // Reactive
    private let stateSubject = PassthroughSubject<ReactiveOneInputDateViewState, Never>()
    
    @IBOutlet private weak var dateTextField: ConfigurableActionsTextField!
    @IBOutlet private weak var calendarImage: UIImageView!
    @IBOutlet private weak var borderContentView: UIView!
    @IBOutlet private weak var selectDateButton: UIButton!
    
    private var viewModel: OneInputDateViewModel?
    private var status: OneStatus? {
        didSet {
            self.updateByStatus()
        }
    }
    private var datePicker: UIDatePicker?
    private var previousDate: Date?
    public weak var delegate: OneInputDateViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    public init(with viewModel: OneInputDateViewModel) {
        super.init(frame: .zero)
        self.configureView()
        self.setViewModel(viewModel)
    }
    
    public func setViewModel(_ viewModel: OneInputDateViewModel) {
        self.viewModel = viewModel
        self.configureByStatus(viewModel)
        self.setPickerLocale()
        self.setAccessibilitySuffix(viewModel.accessibilitySuffix ?? "")
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }

    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }

    public func setOneStatus(_ status: OneStatus) {
        self.status = status
        if status == .activated || status == .focused {
            self.previousDate = self.datePicker?.date
        }
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    public func setMinDate(_ date: Date) {
        self.datePicker?.minimumDate = date
        self.updateMinDate(date)
    }
    
    public func setDate(_ date: Date) {
        self.dateTextField.text = date.toString(format: TimeFormat.dd_MM_yyyy.rawValue)
    }
    
    public func clearDateTextField() {
        self.dateTextField.text = ""
    }
}

private extension OneInputDateView {
    func configureView() {
        self.configureBorderContentView()
        self.configureLabels()
        self.configurePicker()
        self.configureImage()
        self.setAccessibilityIdentifiers()
    }
    
    func configureByStatus(_ viewModel: OneInputDateViewModel) {
        self.setPickerDates(with: viewModel)
        self.setDateTexts(with: viewModel)
        self.setOneStatus(viewModel.status)
        self.updateDateTextField()
    }
    
    func setPickerLocale() {
        self.datePicker?.locale = self.viewModel?.dependenciesResolver.resolve(for: AppRepositoryProtocol.self).getCurrentLanguage().locale
    }
    
    func updateByStatus() {
        self.updateBorderContentView()
        self.updateLabels()
        self.updateImage()
    }
    
    func configureBorderContentView() {
        self.borderContentView.setOneCornerRadius(type: .oneShRadius8)
    }
    
    func configureLabels() {
        self.dateTextField.borderStyle = .none
        self.dateTextField.font = .typography(fontName: .oneH100Regular)
        self.dateTextField.setDisabledActions(TextFieldActions.usuallyDisabledActions)
        self.dateTextField.tintColor = .clear
        self.dateTextField.delegate = self
        self.dateTextField.placeholder = ""
    }
    
    func configurePicker() {
        let datePicker = self.getDatePicker()
        self.dateTextField.inputView = datePicker
        self.dateTextField.isUserInteractionEnabled = true
        self.datePicker = datePicker
        let toolBar = self.getDatePickerToolbar()
        self.dateTextField.inputAccessoryView = toolBar
    }
    
    func configureImage() {
        self.calendarImage.image = Assets.image(named: "icnCalendar")
        self.calendarImage.image = self.calendarImage.image?.withRenderingMode(.alwaysTemplate)
        self.calendarImage.tintColor = .oneDarkTurquoise
    }
    
    func setDateTexts(with viewModel: OneInputDateViewModel) {
        if let date = viewModel.firstDate {
            self.dateTextField.text = date.toString(format: TimeFormat.dd_MM_yyyy.rawValue)
        }
        self.dateTextField.attributedPlaceholder = NSAttributedString(string: localized(viewModel.placeholderKey ?? ""),
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.oneLisboaGray.withAlphaComponent(0.5)])
    }
    
    func updateBorderContentView() {
        self.borderContentView.drawBorder(color: self.borderColor)
        self.borderContentView.setOneShadows(type: self.shadowStyle)
        self.borderContentView.backgroundColor = self.backGroundColor
    }
    
    func updateLabels() {
        self.dateTextField.textColor = self.selectedInputLabelColor
    }
    
    func updateImage() {
        self.calendarImage.tintColor = self.calendarImageColor
    }
    
    func setPickerDates(with viewModel: OneInputDateViewModel) {
        if let date = viewModel.firstDate {
            self.datePicker?.date = date
            self.dateTextField.text = date.toString(format: TimeFormat.dd_MM_yyyy.rawValue)
        }
        self.datePicker?.minimumDate = viewModel.minDate
        self.datePicker?.maximumDate = viewModel.maxDate
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.view?.accessibilityIdentifier = AccessibilityOneComponents.oneInputDateView + (suffix ?? "")
        self.dateTextField.accessibilityIdentifier = AccessibilityOneComponents.oneInputDateTextField + (suffix ?? "")
        self.calendarImage.accessibilityIdentifier = AccessibilityOneComponents.oneInputDateIcn + (suffix ?? "")
    }
    
    func setAccessibilityInfo() {
        self.dateTextField.isAccessibilityElement = false
        let accessibilityLabelKey = self.viewModel?.accessibilityLabelKey
        let accessibilityLabel = accessibilityLabelKey != nil ? localized(accessibilityLabelKey ?? "", [StringPlaceholder(.date, self.getDateString() ?? "")]).text : self.getDateString()
        self.selectDateButton.accessibilityLabel = accessibilityLabel
        self.selectDateButton.accessibilityValue = localized("voiceover_openCalendar")
        self.selectDateButton.accessibilityTraits = self.status == .disabled ? .notEnabled : .button
    }
    
    func getDateString() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        guard let dateString = self.dateTextField.text,
              let date = dateFormatter.date(from: dateString) else { return self.dateTextField.text }
        return DateFormatter.localizedString(from: date,
                                             dateStyle: .long,
                                             timeStyle: .none)
    }
    
    func resetPickerToLastDate() {
        guard let picker = self.dateTextField.inputView as? UIDatePicker else { return }
        if let previousDate = self.previousDate {
            picker.setDate(previousDate, animated: false)
        } else {
            self.status = .inactive
        }
        self.updateDateTextField()
    }
    
    func getDatePicker() -> UIDatePicker {
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: Constants.datePickerWidth, height: Constants.datePickerHeight))
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        return datePicker
    }
    
    func getDatePickerToolbar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.isTranslucent = true
        toolBar.tintColor = .oneDarkTurquoise
        toolBar.backgroundColor = .oneSkyGray
        toolBar.sizeToFit()
        let buttons = self.getToolbarButtons()
        toolBar.setItems(buttons, animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    
    func getToolbarButtons() -> [UIBarButtonItem] {
        let doneButton = UIBarButtonItem(title: localized("generic_button_accept"), style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneButtonPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: localized("generic_button_cancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelPressed))
        doneButton.setTitleTextAttributes([.foregroundColor: UIColor.oneDarkTurquoise], for: [.normal, .highlighted])
        cancelButton.setTitleTextAttributes([.foregroundColor: UIColor.oneDarkTurquoise], for: [.normal, .highlighted])
        return [cancelButton, spaceButton, doneButton]
    }
    
    func updateDateTextField() {
        guard self.shouldShowDate(),
              let datePicker = self.dateTextField.inputView as? UIDatePicker else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = TimeFormat.dd_MM_yyyy.rawValue
        self.dateTextField.text = dateFormatter.string(from: datePicker.date)
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    func shouldShowDate() -> Bool {
        return self.status == .activated || self.status == .focused
    }
    
    @IBAction func didTapOnOneDatePicker(_ sender: Any) {
        self.dateTextField.becomeFirstResponder()
    }
    
    @objc func cancelPressed() {
        self.dateTextField.endEditing(false)
        self.delegate?.didSelectCancelOption()
    }
    
    @objc func doneButtonPressed() {
        guard let datePicker = self.datePicker else { return }
        self.updateDateTextField()
        self.previousDate = datePicker.date
        self.delegate?.didSelectNewDate(datePicker.date)
        self.stateSubject.send(.didSelectNewDate(datePicker.date))
        self.dateTextField.resignFirstResponder()
    }
    
    func updateMinDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = TimeFormat.dd_MM_yyyy.rawValue
        let dateTextField = dateFormatter.date(from: self.dateTextField.text ?? "") ?? Date()
        if dateTextField < date {
            self.dateTextField.text = date.toString(format: TimeFormat.dd_MM_yyyy.rawValue)
        }
    }
}

private extension OneInputDateView {
    var backGroundColor: UIColor {
        switch self.status {
        case .inactive, .activated, .focused: return .oneWhite
        case .disabled: return .oneLightGray40
        case .error, .none: return .oneWhite
        }
    }
    
    var borderColor: UIColor {
        switch self.status {
        case .inactive, .activated: return .oneBrownGray
        case .focused: return .oneDarkTurquoise
        case .disabled: return .oneBrownGray
        case .error, .none: return .oneBostonRed
        }
    }
    
    var shadowStyle: OneShadowsType {
        switch self.status {
        case .inactive, .activated, .focused: return .oneShadowSmall
        case .disabled: return .none
        case .error, .none: return .oneShadowSmall
        }
    }
    
    var selectedInputLabelColor: UIColor {
        switch self.status {
        case .activated, .focused: return .oneLisboaGray
        case .inactive, .disabled: return .oneBrownishGray
        case .error, .none: return .oneLisboaGray
        }
    }
    
    var calendarImageColor: UIColor {
        switch self.status {
        case .inactive, .activated, .focused: return .oneDarkTurquoise
        case .disabled: return .oneBrownishGray
        case .error, .none: return .oneDarkTurquoise
        }
    }
}

extension OneInputDateView: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.status = .focused
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard self.status != .disabled else { return false }
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.status = .activated
        self.resetPickerToLastDate()
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
}

extension OneInputDateView: AccessibilityCapable {}

extension OneInputDateView: ReactiveOneInputDateView {

    public var publisher: AnyPublisher<ReactiveOneInputDateViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
}
