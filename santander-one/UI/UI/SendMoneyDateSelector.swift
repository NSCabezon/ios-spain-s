import Foundation
import CoreFoundationLib

public protocol SendMoneyDateSelectorViewDelegate: AnyObject {
    func didOpenSection(view: UIView)
    func dateDidBeginEditing()
}

protocol SendMoneyDateSelectorProtocol {
    var dateType: SendMoneyDateTypeViewModel { get }
    var oneDayDate: Date? { get }
    var periodicEmissionDate: SendMoneyEmissionTypeViewModel? { get }
    var periodicStartDate: Date? { get }
    var periodicEndDate: Date? { get }
    var periodicPeriodicity: SendMoneyPeriodicityTypeViewModel? { get }
    var periodicEndDateNever: Bool { get }
    func set(type: SendMoneyDateTypeFilledViewModel)
}

public class SendMoneyDateSelector: UIView {
    var dateType: SendMoneyDateTypeViewModel = .now
    public weak var delegate: SendMoneyDateSelectorViewDelegate?
    @IBOutlet private var periodicViews: [UIView]!
    @IBOutlet private var whenDescriptionLabel: UILabel!
    @IBOutlet private var whenSegmentView: UIView!
    @IBOutlet private var whenSegmentControl: LisboaSegmentedControl!
    @IBOutlet private var oneDayView: UIView!
    @IBOutlet private var oneDayDateField: LisboaTextfield! {
        didSet {
            self.oneDayDateField.titleLabel.accessibilityIdentifier = AccessibilityDateSelector.inputScheduledDateTitle.rawValue
            self.oneDayDateField.field.accessibilityIdentifier = AccessibilityDateSelector.inputScheduledDate.rawValue
            self.oneDayDateField.field.addTarget(self, action: #selector(dateDidBeginEditing), for: .editingDidBegin)
        }
    }
    private let periodicPeriodicityField = TextFieldSelectorView<SendMoneyPeriodicityTypeViewModel>()
    private var selectedPeriodicity: SendMoneyPeriodicityTypeViewModel?
    private var differenceOfDaysToDeferredTransfers = 2
    @IBOutlet private weak var periodicityView: UIStackView!
    @IBOutlet private var periodicStartDateField: LisboaTextfield! {
        didSet {
            self.periodicStartDateField.titleLabel.accessibilityIdentifier = AccessibilityDateSelector.inputStartDateTitle.rawValue
            self.periodicStartDateField.field.accessibilityIdentifier = AccessibilityDateSelector.inputStartDate.rawValue
            self.periodicStartDateField.field.addTarget(self, action: #selector(dateDidBeginEditing), for: .editingDidBegin)
        }
    }
    @IBOutlet private var periodicEndDateField: LisboaTextfield! {
        didSet {
            self.periodicEndDateField.titleLabel.accessibilityIdentifier = AccessibilityDateSelector.inputEndDateTitle.rawValue
            self.periodicEndDateField.field.accessibilityIdentifier = AccessibilityDateSelector.inputEndDate.rawValue
            self.periodicEndDateField.field.addTarget(self, action: #selector(dateDidBeginEditing), for: .editingDidBegin)
        }
    }
    @IBOutlet private var periodicEndDateNeverButton: UIButton! {
        didSet {
            self.periodicEndDateNeverButton.accessibilityIdentifier = AccessibilityDateSelector.btnEndDateNever.rawValue
        }
    }
    @IBOutlet private var periodicEndDateNeverLabel: UILabel! {
        didSet {
            self.periodicEndDateNeverLabel.accessibilityIdentifier = AccessibilityDateSelector.labelEndDateNever.rawValue
        }
    }
    @IBOutlet private var periodicEmissionDateField: LisboaTextfield! {
        didSet {
            self.periodicEmissionDateField.titleLabel.accessibilityIdentifier = AccessibilityDateSelector.inputEmissionDateTitle.rawValue
            self.periodicEmissionDateField.field.accessibilityIdentifier = AccessibilityDateSelector.inputEmissionDate.rawValue
            self.periodicEmissionDateField.field.addTarget(self, action: #selector(dateDidBeginEditing), for: .editingDidBegin)
        }
    }
    
   public var sectionResponder: EditSectionResponder? {
        if oneDayDateField.isFirstResponder {
            return .oneDayDate
        } else if periodicStartDateField.isFirstResponder {
            return .periodicStartDate
        } else if periodicEndDateField.isFirstResponder {
            return .periodicEndDate
        } else if periodicEmissionDateField.isFirstResponder {
            return .periodicEmissionDate
        } else {
            return nil
        }
    }
    
    public var fieldSectionResponder: LisboaTextfield? {
        switch sectionResponder {
        case .oneDayDate?:
            return oneDayDateField
        case .periodicStartDate?:
            return periodicStartDateField
        case .periodicEndDate?:
            return periodicEndDateField
        case .periodicEmissionDate?:
            return periodicEmissionDateField
        case .none:
            return nil
        }
    }
    
    public var periodicityTypes: [SendMoneyPeriodicityTypeViewModel] = []
    
    // MARK: - Class Methods
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Actions Methods
    @IBAction func changeNeverEndDate() {
        self.periodicEndDateNeverButton.isSelected = !self.periodicEndDateNeverButton.isSelected
        if self.periodicEndDateNeverButton.isSelected {
            periodicEndDateField.updateData(text: nil)
        } else if let startDate = self.periodicStartDate {
            let dateEnd = startDate.getDateByAdding(days: 1)
            createDatePicker(for: periodicEndDateField, date: dateEnd, minimumDate: dateEnd)
            periodicEndDateField.updateData(text: convertDateToString(from: dateEnd))
        }
    }
    
    @IBAction func changeWhenSegment() {
        switch whenSegmentControl.selectedSegmentIndex {
        case 0:
            updateWithType(type: .now)
        case 1:
            updateWithType(type: .day)
        case 2:
            updateWithType(type: .periodic)
        default:
            break
        }
    }
    
    @objc public func donePicker() {
        switch sectionResponder {
        case .none:
            break
        case .oneDayDate:
            if let datePicker = oneDayDateField?.field.inputView as? UIDatePicker {
                let date = datePicker.date
                oneDayDateField.updateData(text: convertDateToString(from: date))
                updatePeriodicStartDate(date)
                let dateEnd = date.getDateByAdding(days: 1)
                createDatePicker(for: periodicEndDateField, date: dateEnd, minimumDate: dateEnd)
            }
        case .periodicStartDate:
            if let datePicker = periodicStartDateField?.field.inputView as? UIDatePicker {
                let date = datePicker.date
                let dateEnd = date.getDateByAdding(days: 1)
                if !self.periodicEndDateNeverButton.isSelected, let periodicEndDate = self.periodicEndDate {
                    if periodicEndDate.compare(date) != .orderedDescending {
                        createDatePicker(for: periodicEndDateField, date: dateEnd, minimumDate: dateEnd)
                        periodicEndDateField.updateData(text: convertDateToString(from: dateEnd))
                    }
                } else {
                    createDatePicker(for: periodicEndDateField, date: dateEnd, minimumDate: dateEnd)
                }
                periodicStartDateField.updateData(text: convertDateToString(from: date))
                updateOneDayFieldDate(date)
            }
        case .periodicEndDate:
            if let datePicker = periodicEndDateField?.field.inputView as? UIDatePicker {
                let date = datePicker.date
                periodicEndDateField.updateData(text: convertDateToString(from: date))
                self.periodicEndDateNeverButton.isSelected = false
            }
        case .periodicEmissionDate:
            if let picker = fieldSectionResponder?.field.inputView as? UIPickerView, let emission = SendMoneyEmissionTypeViewModel(rawValue: picker.selectedRow(inComponent: 0)) {
                periodicEmissionDateField.updateData(text: localized(emission.text))
            }
        }
        self.endEditing(true)
    }
    @objc func cancelPicker() {
        self.endEditing(true)
    }
    
    public func getTransferTime() -> SendMoneyDateTypeFilledViewModel {
        switch self.dateType {
        case .now:
            return .now
        case .day:
            return .day(date: oneDayDate ?? Date())
        case .periodic:
            let periodicity: SendMoneyPeriodicityTypeViewModel
            switch periodicPeriodicity {
            case .month, .none:
                periodicity = .month
            case .quarterly:
                periodicity = .quarterly
            case .semiannual:
                periodicity = .semiannual
            case .weekly:
                periodicity = .weekly
            case .bimonthly:
                periodicity = .bimonthly
            case .annual:
                periodicity = .annual
            }
            let emission: SendMoneyEmissionTypeViewModel
            switch periodicEmissionDate {
            case .next, .none:
                emission = .next
            case .previous:
                emission = .previous
            }
            let periodicEndDateModel: PeriodicEndDateTypeFilledViewModel
            if periodicEndDateNever {
                periodicEndDateModel = .never
            } else {
                periodicEndDateModel = .date(periodicEndDate ?? Date())
            }
            return .periodic(start: periodicStartDate ?? Date(), end: periodicEndDateModel, periodicity: periodicity, emission: emission)
        }
    }
    
    public func hidePeriodicEmissionDateField() {
        self.periodicEmissionDateField.isHidden = true
    }
    
    public func setupPeriodicityModel(with model: [SendMoneyPeriodicityTypeViewModel]) {
        self.periodicityTypes = model
        self.periodicPeriodicityField.configureWithProducts(model, title: "") { [weak self] periodicity in
            self?.selectedPeriodicity = periodicity
        }
        if let defaultPeriodicity = model.first {
            self.periodicPeriodicityField.selectElement(defaultPeriodicity)
            self.selectedPeriodicity = defaultPeriodicity
        }
    }
    
    public func setDefaultValues(addingDays: Int) {
        self.differenceOfDaysToDeferredTransfers = addingDays
        switch self.dateType {
        case .now:
            self.setDefaultValuesDay()
            self.setDefaultValuesPeriodic()
            self.resetOneDayDateAndStartDate()
        case .day:
            self.setDefaultValuesPeriodic()
        case .periodic:
            self.setDefaultValuesDay()
        }
    }
    
    public func setDateTypeSaved(dateTypeModel: SendMoneyDateTypeFilledViewModel) {
        switch dateTypeModel {
        case .now:
            self.dateType = .now
        case .day(let date):
            self.dateType = .day
            self.setOneDayValueSaved(date: date)
        case .periodic(let start, let end, let periodicity, _):
            self.dateType = .periodic
            self.setPeriodicValuesSaved(start: start, end: end, periodicity: periodicity)
        }
        self.updateTypeState()
    }
}

// MARK: - Private Methods
private extension SendMoneyDateSelector {
    func setupView() {
        self.xibSetup()
        self.backgroundColor = UIColor.white
        self.periodicEndDateNeverButton.setImage(Assets.image(named: "checkboxSelected"), for: UIControl.State.selected)
        self.periodicEndDateNeverButton.setImage(Assets.image(named: "checkboxDefault"), for: UIControl.State.normal)
        self.periodicEndDateNeverLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        self.periodicEndDateNeverLabel.textColor = UIColor.lisboaGray
        self.periodicEndDateNeverLabel.text = localized("sendMoney_label_indefinite")
        self.whenDescriptionLabel.textColor = UIColor.lisboaGray
        self.whenDescriptionLabel.font = UIFont.santander(family: .text, type: .bold, size: 16)
        self.whenDescriptionLabel.text = localized("transfer_label_periodicity")
        self.whenDescriptionLabel.accessibilityIdentifier = AccessibilityDateSelector.periodicityLabel.rawValue
        self.whenSegmentView.backgroundColor = UIColor.skyGray
        self.whenSegmentView.layer.borderColor = UIColor.skyGray.cgColor
        self.whenSegmentView.layer.borderWidth = 1
        self.whenSegmentView.layer.cornerRadius = 5
        self.whenSegmentView.clipsToBounds = true
        self.whenSegmentControl.setup(with: [localized("sendMoney_tab_today"),
                                             localized("sendMoney_tab_chooseDay"),
                                             localized("sendMoney_tab_periodic")],
                                      accessibilityIdentifiers: ["sendMoney_tab_today",
                                                                 "sendMoney_tab_chooseDay",
                                                                 "sendMoney_tab_periodic"],
                                      withStyle: .defaultSegmentedControlStyle)
        let conceptFormmater = UIFormattedCustomTextField()
        conceptFormmater.setMaxLength(maxLength: 140)
        self.oneDayDateField.configure(with: nil, title: localized("sendMoney_label_issuanceDate"), extraInfo: (image: Assets.image(named: "btnCalendar"), action: { [weak self] in
            self?.oneDayDateField.field.becomeFirstResponder()
        }), disabledActions: TextFieldActions.usuallyDisabledActions)
        self.periodicStartDateField.configure(with: nil, title: localized("sendMoney_label_startDate"), extraInfo: (image: Assets.image(named: "btnCalendar"), action: { [weak self] in
            self?.periodicStartDateField.field.becomeFirstResponder()
        }), disabledActions: TextFieldActions.usuallyDisabledActions)
        self.periodicEndDateField.configure(with: nil, title: localized("sendMoney_label_endDate"), extraInfo: (image: Assets.image(named: "btnCalendar"), action: { [weak self] in
            self?.periodicEndDateField.field.becomeFirstResponder()
        }), disabledActions: TextFieldActions.usuallyDisabledActions)
        self.periodicEmissionDateField.configure(with: nil, title: localized("sendMoney_label_workingDayIssue"), extraInfo: (image: Assets.image(named: "icnArrowDownGreen"), action: { [weak self] in
            self?.periodicEmissionDateField.field.becomeFirstResponder()
        }), disabledActions: TextFieldActions.usuallyDisabledActions)
        createPicker(for: periodicEmissionDateField, index: nil)
        let dateStart = Date().getDateByAdding(days: self.differenceOfDaysToDeferredTransfers)
        let dateEnd = Date().getDateByAdding(days: self.differenceOfDaysToDeferredTransfers + 1)
        createDatePicker(for: oneDayDateField, date: dateStart, minimumDate: dateStart)
        oneDayDateField.updateData(text: convertDateToString(from: dateStart))
        periodicStartDateField.updateData(text: convertDateToString(from: dateStart))
        createDatePicker(for: periodicStartDateField, date: dateStart, minimumDate: dateStart)
        createDatePicker(for: periodicEndDateField, date: dateEnd, minimumDate: dateEnd)
        self.periodicPeriodicityField.setDropdownAccessibilityIdentifier(AccessibilityDateSelector.inputPeriodicity.rawValue)
        self.periodicityView.addArrangedSubview(self.periodicPeriodicityField)
        self.periodicEndDateNeverButton.isSelected = true
        updateTypeState()
    }
    func xibSetup() {
        let view = loadViewFromNib()
        view.frame = bounds
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    func convertDateToString(from date: Date) -> String? {
        return dateToString(date: date, outputFormat: TimeFormat.dd_MMM_yyyy)?.capitalized
    }
    func updateWithType(type: SendMoneyDateTypeViewModel) {
        if self.dateType != type {
            self.dateType = type
            self.updateTypeState()
        }
    }
    func updateTypeState() {
        let index: Int
        switch dateType {
        case .now:
            index = 0
            hideOneDay()
            hidePeriodic()
        case .day:
            index = 1
            showOneDay()
            hidePeriodic()
        case .periodic:
            index = 2
            hideOneDay()
            showPeriodic()
        }
        self.whenSegmentControl.selectedSegmentIndex = index
    }
    func showOneDay() {
        self.oneDayView.isHidden = false
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.oneDayView.alpha = 1
        }, completion: { _ in
            self.delegate?.didOpenSection(view: self)
        })
    }
    func hideOneDay() {
        oneDayView.alpha = 0
        oneDayView.isHidden = true
    }
    func showPeriodic() {
        self.periodicViews.forEach { $0.isHidden = false }
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.periodicViews.forEach { $0.alpha = 1 }
        }, completion: { _ in
            self.delegate?.didOpenSection(view: self)
        })
    }
    func hidePeriodic() {
        periodicViews.forEach { $0.isHidden = true }
        periodicViews.forEach { $0.alpha = 0 }
    }
    
    func createPicker(for field: LisboaTextfield, index: Int?) {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.showsSelectionIndicator = true
        picker.selectRow(index ?? 0, inComponent: 0, animated: false)
        field.field.inputView = picker
    }
    func createDatePicker(for field: LisboaTextfield, date: Date, minimumDate: Date) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.date = date
        datePicker.locale = NSLocale.current
        datePicker.timeZone = TimeZone(abbreviation: "GMT")
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = nil
        field.field.inputView = datePicker
    }
    
    @objc func dateDidBeginEditing() {
        self.delegate?.dateDidBeginEditing()
    }
    
    func setDefaultValuesPeriodic() {
        self.periodicEndDateField.updateData(text: nil)
        self.periodicEndDateNeverButton.isSelected = true
        if let defaultPeriodicity = self.periodicityTypes.first {
            self.periodicPeriodicityField.selectElement(defaultPeriodicity)
            self.selectedPeriodicity = defaultPeriodicity
        }
        periodicEmissionDateField.updateData(text: localized(SendMoneyEmissionTypeViewModel.previous.text))
        createPicker(for: periodicEmissionDateField, index: nil)
        let dateStart = Date().getDateByAdding(days: self.differenceOfDaysToDeferredTransfers)
        let dateEnd = Date().getDateByAdding(days: self.differenceOfDaysToDeferredTransfers + 1)
        createDatePicker(for: periodicEndDateField, date: dateEnd, minimumDate: dateEnd)
        if let date = self.oneDayDate {
            periodicStartDateField.updateData(text: convertDateToString(from: date))
            createDatePicker(for: periodicStartDateField, date: date, minimumDate: dateStart)
        } else {
            periodicStartDateField.updateData(text: convertDateToString(from: dateStart))
            createDatePicker(for: periodicStartDateField, date: dateStart, minimumDate: dateStart)
        }
    }
    
    func setDefaultValuesDay() {
        let minimumDate = Date().getDateByAdding(days: self.differenceOfDaysToDeferredTransfers)
        if let date = self.periodicStartDate {
            oneDayDateField.updateData(text: convertDateToString(from: date))
            createDatePicker(for: oneDayDateField, date: date, minimumDate: minimumDate)
        } else {
            oneDayDateField.updateData(text: convertDateToString(from: minimumDate))
            createDatePicker(for: oneDayDateField, date: minimumDate, minimumDate: minimumDate)
        }
    }
    
    func resetOneDayDateAndStartDate() {
        let dateStart = Date().getDateByAdding(days: self.differenceOfDaysToDeferredTransfers)
        periodicStartDateField.updateData(text: convertDateToString(from: dateStart))
        createDatePicker(for: periodicStartDateField, date: dateStart, minimumDate: dateStart)
        oneDayDateField.updateData(text: convertDateToString(from: dateStart))
        createDatePicker(for: oneDayDateField, date: dateStart, minimumDate: dateStart)
    }
    
    func setPeriodicValuesSaved(start: Date, end: PeriodicEndDateTypeFilledViewModel, periodicity: SendMoneyPeriodicityTypeViewModel) {
        updatePeriodicStartDate(start)
        updateOneDayFieldDate(start)
        switch end {
        case .date(let endDate):
            self.periodicEndDateNeverButton.isSelected = false
            let minimunDate = start.getDateByAdding(days: 1)
            createDatePicker(for: periodicEndDateField, date: endDate, minimumDate: minimunDate)
            periodicEndDateField.updateData(text: convertDateToString(from: endDate))
            if let datePickerPeriodicEnd = periodicEndDateField?.field.inputView as? UIDatePicker {
                datePickerPeriodicEnd.setDate(endDate, animated: false)
            }
        case .never:
            self.periodicEndDateNeverButton.isSelected = true
            let dateEnd = start.getDateByAdding(days: 1)
            createDatePicker(for: periodicEndDateField, date: dateEnd, minimumDate: dateEnd)
        }
        self.periodicPeriodicityField.selectElement(periodicity)
        self.selectedPeriodicity = periodicity
    }
    
    func setOneDayValueSaved(date: Date) {
        updateOneDayFieldDate(date)
        updatePeriodicStartDate(date)
        let dateEnd = date.getDateByAdding(days: 1)
        createDatePicker(for: periodicEndDateField, date: dateEnd, minimumDate: dateEnd)
    }
    
    func updateOneDayFieldDate(_ date: Date) {
        oneDayDateField.updateData(text: convertDateToString(from: date))
        if let datePickerOneDay = oneDayDateField?.field.inputView as? UIDatePicker {
            datePickerOneDay.setDate(date, animated: false)
        }
    }
    
    func updatePeriodicStartDate(_ date: Date) {
        periodicStartDateField.updateData(text: convertDateToString(from: date))
        if let datePickerPeriodicStart = periodicStartDateField?.field.inputView as? UIDatePicker {
            datePickerPeriodicStart.setDate(date, animated: false)
        }
    }
}

// MARK: - UIPickerView
extension SendMoneyDateSelector: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch sectionResponder {
        case .oneDayDate?, .periodicStartDate?, .periodicEndDate?, .none:
            return nil
        case .periodicEmissionDate:
            return localized(SendMoneyEmissionTypeViewModel.allCases[row].text)
        }
    }
}

extension SendMoneyDateSelector: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch sectionResponder {
        case .oneDayDate?, .periodicStartDate?, .periodicEndDate?, .none:
            return 0
        case .periodicEmissionDate:
            return SendMoneyEmissionTypeViewModel.allCases.count
        }
    }
}

extension SendMoneyDateSelector: SendMoneyDateSelectorProtocol {
    var periodicPeriodicity: SendMoneyPeriodicityTypeViewModel? {
        return self.selectedPeriodicity
    }
    var periodicEmissionDate: SendMoneyEmissionTypeViewModel? {
        return SendMoneyEmissionTypeViewModel(rawValue: (periodicEmissionDateField.field.inputView as? UIPickerView)?.selectedRow(inComponent: 0) ?? 0)
    }
    var oneDayDate: Date? {
        return (oneDayDateField.field.inputView as? UIDatePicker)?.date
    }
    var periodicStartDate: Date? {
        return (periodicStartDateField.field.inputView as? UIDatePicker)?.date
    }
    var periodicEndDate: Date? {
        return (periodicEndDateField.field.inputView as? UIDatePicker)?.date
    }
    var periodicEndDateNever: Bool {
        return self.periodicEndDateNeverButton.isSelected
    }
    func set(type: SendMoneyDateTypeFilledViewModel) {
        updateTypeState()
        
        switch type {
        case .now:
            updateWithType(type: .now)
        case .day(let date):
            oneDayDateField.updateData(text: convertDateToString(from: date))
            updateWithType(type: .day)
        case .periodic(let start, let end, _, let emission):
            periodicStartDateField.updateData(text: convertDateToString(from: start))
            switch end {
            case .never:
                periodicEndDateField.updateData(text: nil)
                self.periodicEndDateNeverButton.isSelected = true
            case .date(let date):
                periodicEndDateField.updateData(text: convertDateToString(from: date))
                self.periodicEndDateNeverButton.isSelected = false
            }
            periodicEmissionDateField.updateData(text: localized(emission.text))
            createPicker(for: periodicEmissionDateField, index: emission.rawValue)
            updateWithType(type: .periodic)
        }
    }
}
// MARK: - ViewModels
public enum EditSectionResponder {
    case oneDayDate
    case periodicStartDate
    case periodicEndDate
    case periodicEmissionDate
}

extension SendMoneyPeriodicityTypeViewModel: DropdownElement {
    public var name: String {
        return localized(self.text)
    }
}
