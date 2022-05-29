//  DateFilterView.swift
//  UI
//
//  Created by David Gálvez Alonso on 31/01/2020.
//

import CoreFoundationLib
import OpenCombine
import Metal

public protocol DateFilterViewDelegate: AnyObject {
    func didOpenSection(view: UIView)
    func getLanguage() -> String
}

#warning("TODO: The class needs a refactor")
// swiftlint:disable type_body_length
public class DateFilterView: UIDesignableView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeSegmentedControl: LisboaSegmentedControl!
    @IBOutlet weak var timeSegmentedView: UIView!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var monthStackView: MultiselectionStackView!
    @IBOutlet weak var leftArrowImage: UIImageView!
    @IBOutlet weak var rightArrowImage: UIImageView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var leftArrowContentView: UIView!
    @IBOutlet weak var rightArrowContentView: UIView!
    @IBOutlet weak var startDateTextField: SmallLisboaTextField!
    @IBOutlet weak var endDateTextField: SmallLisboaTextField!
    @IBOutlet weak var informationImage: UIImageView!
    @IBOutlet weak var informationButton: UIButton!
    private var informationAction: ((UIView) -> Void)?
    public weak var delegate: DateFilterViewDelegate?
    private var keyNames: [String] = [
        "search_tab_last7Days",
        "search_tab_last30Days",
        "search_tab_last90Days",
        "search_label_months"
    ]
    private var rangeDateArray: [RangeDateTypeViewModel] = [
        .lastSevenDays(-7),
        .lastThirtyDays(-30),
        .lastCustomDays(-89),
        .monthsRange,
        .customDateRange
    ]
    
    private var sectionResponder: EditSectionResponder? {
        if startDateTextField.isFirstResponder {
            return .startDate
        } else if endDateTextField.isFirstResponder {
            return .endDate
        } else {
            return nil
        }
    }
    
    fileprivate enum EditSectionResponder {
        case startDate
        case endDate
    }
    
    fileprivate enum RangeDateTypeViewModel {
        case lastSevenDays(Int)
        case lastThirtyDays(Int)
        case lastCustomDays(Int)
        case monthsRange
        case customDateRange
    }
    
    private var startDate: Date {
        return (startDateTextField.field.inputView as? UIDatePicker)?.date ?? currentDate
    }
    private var endDate: Date {
        return (endDateTextField.field.inputView as? UIDatePicker)?.date ?? currentDate
    }
    
    private var selectedMonth: String = ""
    private var selectedYear: String?
    
    private let currentDate = Date()
    private var selectedDate: Date?
    private var isCustomRangeDate = false
    private let limitMinimumDate = Calendar.current.date(byAdding: DateComponents(month: -25), to: Date()) ?? Date()
    private var previousStartDateBeforeEditing: Date?
    private var previousEndDateBeforeEditing: Date?
    
    private var sceneLanguage: String?
    public var onDidOpenSectionSubject = PassthroughSubject<UIView, Never>()
    
    override public func commonInit() {
        super.commonInit()
        configureTitleLabel()
        configureMonthView()
        configureSegmentedView()
        setAccessibility()
    }
    
    private func configureTitleLabel() {
        titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 16)
        titleLabel.text = localized("search_label_datesRange")
        titleLabel.textColor = UIColor.lisboaGray
    }
    
    private func configureSegmentedView() {
        self.timeSegmentedControl.setup(with: self.keyNames,
                                        accessibilityIdentifiers: ["search_tab_last7Days", "search_tab_last30Days", "search_tab_last90Days", "search_label_months"],
                                        withStyle: .defaultSegmentedControlStyle)

        self.timeSegmentedControl.selectedSegmentIndex = 2
        updateTypeState(self.rangeDateArray[2])
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
    }
    
    public func setCustomDateRange(localizedKey: String, days: Int, at index: Int) {
        self.keyNames[index] = localizedKey
        self.timeSegmentedControl.setup(with: keyNames)
        self.timeSegmentedControl.selectedSegmentIndex = index
        self.rangeDateArray[index] = .lastCustomDays(days)
        self.updateTypeState(self.rangeDateArray[index])
    }
    
    public func setSceneLanguage(lang: String) {
        self.sceneLanguage = lang
    }
    
    public func configureTextFields() {
        startDateTextField.configure(with: nil,
                                     title: localized("search_label_startDate"),
                                     style: .default,
                                     extraInfo: (image: Assets.image(named: "btnCalendar"), action: { self.startDateTextField.field.becomeFirstResponder() }),
                                     disabledActions: TextFieldActions.usuallyDisabledActions)
        endDateTextField.configure(with: nil,
                                   title: localized("search_label_endDate"),
                                   extraInfo: (image: Assets.image(named: "btnCalendar"),
                                               action: { self.endDateTextField.field.becomeFirstResponder() }),
                                   disabledActions: TextFieldActions.usuallyDisabledActions)
        startDateTextField.field.font = UIFont.santander(family: .text, type: .regular, size: 16)
        endDateTextField.field.font = UIFont.santander(family: .text, type: .regular, size: 16)
        startDateTextField.updateData(text: ".")
        endDateTextField.updateData(text: ".")
        createDatePicker(for: startDateTextField, date: currentDate, minimumDate: limitMinimumDate)
        createDatePicker(for: endDateTextField, date: currentDate, minimumDate: limitMinimumDate)
        startDateTextField.field.adjustsFontSizeToFitWidth = true
        endDateTextField.field.adjustsFontSizeToFitWidth = true
        startDateTextField.field.minimumFontSize = 12
        endDateTextField.field.minimumFontSize = 12
    }
    
    public func setDateSelected(_ startDateSelected: Date, _ endDateSelected: Date) {
        selectedDate = endDateSelected
        self.setDatePickerView(textField: startDateTextField, date: startDateSelected)
        self.setDatePickerView(textField: endDateTextField, date: endDateSelected)
        self.changeTimeSegmentedControlColor(isSelected: false, type: nil)
    }
    
    public func setSelectedIndex(_ index: Int) {
        guard -1...3 ~= index else { return }
        let dateRange: RangeDateTypeViewModel
        if index == -1 {
            dateRange = rangeDateArray[4]
        } else {
            dateRange = rangeDateArray[index]
        }
        self.timeSegmentedControl.selectedSegmentIndex = index
        self.changeTimeSegmentedControlColor(isSelected: false, type: nil)
        self.updateTypeState(dateRange)
    }
    
    public func setDateSelected(_ startDate: Date?, _ endDate: Date?) {
        guard let startDate = startDate, let endDate = endDate else { return }
        self.setDatePickerView(textField: startDateTextField, date: startDate)
        self.setDatePickerView(textField: endDateTextField, date: endDate)
        self.changeTimeSegmentedControlColor(isSelected: true, type: nil)
    }
    
    private func configureMonthView() {
        leftArrowImage.image = Assets.image(named: "icnArrowLeftGray")
        leftArrowContentView.backgroundColor = .white
        leftArrowContentView.layer.cornerRadius = 5
        leftArrowContentView.layer.borderWidth = 1
        leftArrowContentView.layer.borderColor = UIColor(red: 216.0 / 255.0, green: 216.0 / 255.0, blue: 216.0 / 255.0, alpha: 1.0).cgColor
        rightArrowImage.image = Assets.image(named: "icnArrowRightGray")
        rightArrowContentView.backgroundColor = .white
        rightArrowContentView.layer.cornerRadius = 5
        rightArrowContentView.layer.borderWidth = 1
        rightArrowContentView.layer.borderColor = UIColor(red: 216.0 / 255.0, green: 216.0 / 255.0, blue: 216.0 / 255.0, alpha: 1.0).cgColor
        leftArrowContentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(arrowDidPressed(_:))))
        rightArrowContentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(arrowDidPressed(_:))))
        yearLabel.font = UIFont.santander(family: .text, type: .bold, size: 20)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        yearLabel.text = dateFormatter.string(from: currentDate)
        headerView.backgroundColor = UIColor(red: 232.0 / 255.0, green: 232.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
        let allMonths = getAllMonthsStrings()
        let disbledMonths = getDisabledMonths()
        let accessibilityMonths = getAccessibilityIdentifiers()
        monthStackView?.addValues(allMonths.map({ (month) in
            ValueOptionType(value: month, displayableValue: month.camelCasedString, isHighlighted: false, action: { [weak self] in
                self?.setMonth(month: month)
                }, isDisabled: disbledMonths?.contains(month), accessibilityIdentifier: accessibilityMonths[month] ?? "")
        }))
        monthView.layer.borderWidth = 1
        monthView.layer.borderColor = UIColor.lightSkyBlue.cgColor
        monthView.layer.cornerRadius = 5
        monthView.layer.masksToBounds = true
        monthView.isHidden = true
    }
    
    private func setMonth(month: String) {
        selectedYear = yearLabel.text
        selectedMonth = month
        reloadMonthStackView(month: month)
        setMonthDates(month: month)
    }
    
    private func reloadMonthStackView(month: String = "") {
        let disbledMonths = getDisabledMonths()
        monthStackView?.reloadValues(month, disabledOptions: disbledMonths)
    }
    
    private func createDatePicker(for field: LisboaTextfield, date: Date, minimumDate: Date?) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.date = date
        let language = self.obtainLanguage()
        datePicker.locale = Locale(identifier: language)
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = currentDate
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.santanderRed
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: localized("generic_button_accept"), style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: localized("generic_button_cancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelPicker))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        field.field.inputView = datePicker
        field.field.inputAccessoryView = toolBar
        field.field.addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
    }
    
    @objc func cancelPicker() {
        resetPickersToLastDate()
        self.endEditing(true)
    }
    
    private func resetPickersToLastDate() {
        if let startDatePicker = startDateTextField.field.inputView as? UIDatePicker, let previousStartDateBeforeEditing = previousStartDateBeforeEditing {
            startDatePicker.setDate(previousStartDateBeforeEditing, animated: false)
        }
        if let endDatePicker = endDateTextField.field.inputView as? UIDatePicker, let previousEndDateBeforeEditing = previousEndDateBeforeEditing {
            endDatePicker.setDate(previousEndDateBeforeEditing, animated: false)
        }
    }
    
    @objc func arrowDidPressed(_ sender: UITapGestureRecognizer) {
        let value = sender.view == rightArrowContentView ? 1 : -1
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        guard let text = yearLabel.text,
            let date = dateFormatter.date(from: text),
            let modifiedDate = Calendar.current.date(byAdding: .year, value: value, to: date)
            else { return }
        let modifiedDateString = dateFormatter.string(from: modifiedDate)
        let currentDateString = dateFormatter.string(from: currentDate)
        let minimumDateString = dateFormatter.string(from: limitMinimumDate)
        guard modifiedDateString <= currentDateString && modifiedDateString >= minimumDateString else { return }
        yearLabel.text = modifiedDateString
        let month = Calendar.current.isDate(modifiedDate, equalTo: endDate, toGranularity: .year) ? selectedMonth : ""
        reloadMonthStackView(month: month)
    }
    
    @objc func donePicker() {
        switch sectionResponder {
        case .startDate:
            setTextFieldText(startDateTextField)
            if previousStartDateBeforeEditing != startDate {
                updateTypeState(.customDateRange)
            }
        case .endDate:
            setTextFieldText(endDateTextField)
            if previousEndDateBeforeEditing != endDate {
                updateTypeState(.customDateRange)
            }
        case .none:
            return
        }
        self.endEditing(true)
    }
    
    private func changeTimeSegmentedControlColor(isSelected: Bool, type: RangeDateTypeViewModel?) {
        switch type {
        case .customDateRange:
            isCustomRangeDate = true
            timeSegmentedControl.selectedSegmentIndex = -1
        default:
            isCustomRangeDate = false
            timeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: isSelected ? UIColor.lisboaGray : UIColor.darkTorquoise, NSAttributedString.Key.font: UIFont.santander(family: .text, type: isSelected ? .regular : .bold, size: 14)], for: UIControl.State.selected)
            timeSegmentedControl.selectedSegmentIndex = isSelected ? -1 : timeSegmentedControl.selectedSegmentIndex
        }
    }
    
    private func setTextFieldText(_ textField: LisboaTextfield) {
        if let datePicker = textField.field.inputView as? UIDatePicker {
            textField.field.attributedText = getAttibutedString(date: datePicker.date)
            setMinMaxDatePickerView(textField: textField, date: datePicker.date )
        }
    }
    
    private func setDatePickerView(textField: LisboaTextfield, date: Date) {
        let correctedDate = checkMinimumMaximumDate(date: date)
        if let datePicker = textField.field.inputView as? UIDatePicker {
            datePicker.date = correctedDate
            setTextFieldText(textField)
        }
    }
    
    private func setMinMaxDatePickerView(textField: LisboaTextfield, date: Date) {
        if textField == startDateTextField, let datePicker = endDateTextField.field.inputView as? UIDatePicker {
            datePicker.minimumDate = date
        } else if textField == endDateTextField, let datePicker = startDateTextField.field.inputView as? UIDatePicker {
            datePicker.maximumDate = date
        }
    }
    
    private func getAllMonthsStrings() -> [String] {
        let allMonths = ["generic_label_january", "generic_label_february", "generic_label_march", "generic_label_april", "generic_label_may", "generic_label_june", "generic_label_july", "generic_label_august", "generic_label_september", "generic_label_october", "generic_label_november", "generic_label_december"]
        return allMonths.map { localized($0) }
    }
    
    private func getAccessibilityIdentifiers() -> [String: String] {
        let months = getAllMonthsStrings()
        let monthsAccessibilityIds = [AccessibilityTransactionsSearch.btnJanuary.rawValue, AccessibilityTransactionsSearch.btnFebruary.rawValue, AccessibilityTransactionsSearch.btnMarch.rawValue, AccessibilityTransactionsSearch.btnApril.rawValue, AccessibilityTransactionsSearch.btnMay.rawValue, AccessibilityTransactionsSearch.btnJune.rawValue, AccessibilityTransactionsSearch.btnJuly.rawValue, AccessibilityTransactionsSearch.btnAugust.rawValue, AccessibilityTransactionsSearch.btnSeptember.rawValue, AccessibilityTransactionsSearch.btnOctober.rawValue, AccessibilityTransactionsSearch.btnNovember.rawValue, AccessibilityTransactionsSearch.btnDecember.rawValue]
        let monthsJoined = months.enumerated().reduce([String: String]()) { (element, element2) -> [String: String] in
            var element = element
            element[element2.element] = monthsAccessibilityIds[element2.offset]
            return element
        }
        return monthsJoined
    }
    
    private func obtainLanguage() -> String {
        if let lang = self.sceneLanguage {
            return lang
        } else {
            return self.delegate?.getLanguage() ?? "en"
        }
    }
    
    private func getAttibutedString(date: Date) -> NSMutableAttributedString? {
        let dateFormatter = DateFormatter()
        let language = self.obtainLanguage()
        dateFormatter.locale = Locale(identifier: language)
        let attributedString = NSMutableAttributedString()
        let slash = NSAttributedString(string: "/", attributes: [.foregroundColor: UIColor.mediumSkyGray])
        dateFormatter.dateFormat = "dd"
        attributedString.append(NSMutableAttributedString(string: dateFormatter.string(from: date), attributes: [.foregroundColor: UIColor.lisboaGray]))
        attributedString.append(slash)
        dateFormatter.dateFormat = "MMM"
        attributedString.append(NSMutableAttributedString(string: dateFormatter.string(from: date), attributes: [.foregroundColor: UIColor.lisboaGray]))
        attributedString.append(slash)
        dateFormatter.dateFormat = "yyyy"
        attributedString.append(NSMutableAttributedString(string: dateFormatter.string(from: date), attributes: [.foregroundColor: UIColor.lisboaGray]))
        return attributedString
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        changeTimeSegmentedControlColor(isSelected: false, type: nil)
        updateTypeState(self.rangeDateArray[sender.selectedSegmentIndex])
    }
    
    fileprivate func updateTypeState(_ type: RangeDateTypeViewModel?) {
        switch type {
        case .lastSevenDays(let days), .lastThirtyDays(let days), .lastCustomDays(let days):
            guard let modifiedDate = Calendar.current.date(byAdding: .day, value: days, to: currentDate) else { return }
            setDatePickerView(textField: startDateTextField, date: modifiedDate)
            setDatePickerView(textField: endDateTextField, date: currentDate)
            setMonthViewIsHidden(true)
        case .monthsRange:
            if let selectedYear = selectedYear {
                yearLabel.text = selectedYear
            } else if let selectedDate = selectedDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy"
                yearLabel.text = dateFormatter.string(from: selectedDate)
            }
            selectedMonth == "" ? loadMonthView() : setMonth(month: selectedMonth)
            setMonthViewIsHidden(false)
        case .customDateRange:
            changeTimeSegmentedControlColor(isSelected: true, type: .customDateRange)
        default:
            return
        }
    }
    
    func setMonthViewIsHidden(_ isHidden: Bool) {
        guard monthView.isHidden != isHidden else { return }
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.monthView.alpha = isHidden ? 0 : 1
                self.monthView.isHidden = !self.monthView.isHidden
        }, completion: { _ in
            self.delegate?.didOpenSection(view: self)
            self.onDidOpenSectionSubject.send(self)
        })
    }
    
    func loadMonthView() {
        let allmonths = getAllMonthsStrings()
        var startDate = currentDate
        if let selectedDate = selectedDate {
            startDate = selectedDate
        }
        guard let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: startDate))),
            let endOfMonth = Calendar.current.date(byAdding: DateComponents(month: 1, second: -1), to: startOfMonth),
            let monthIndex = Calendar.current.dateComponents([.month], from: startOfMonth).month,
            allmonths.indices.contains(monthIndex - 1)
            else { return }
        setDatePickerView(textField: startDateTextField, date: startOfMonth)
        setDatePickerView(textField: endDateTextField, date: endOfMonth)
        reloadMonthStackView(month: allmonths[monthIndex - 1])
    }
    
    private func setMonthDates(month: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let allMonths = getAllMonthsStrings()
        guard let monthIndex = allMonths.firstIndex(of: month),
            let yearLabelText = yearLabel.text,
            let yearDate = dateFormatter.date(from: yearLabelText),
            let currentSelectedDate = Calendar.current.date(byAdding: DateComponents(month: monthIndex), to: yearDate)
            else { return  }
        setPickerMonthDates(date: currentSelectedDate)
    }
    
    private func setPickerMonthDates(date: Date) {
        guard let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: date))),
            let endOfMonth = Calendar.current.date(byAdding: DateComponents(month: 1, second: -1), to: startOfMonth)
            else { return }
        setDatePickerView(textField: startDateTextField, date: startOfMonth)
        setDatePickerView(textField: endDateTextField, date: endOfMonth)
    }
    
    private func checkMinimumMaximumDate(date: Date) -> Date {
        if date < limitMinimumDate {
            return limitMinimumDate
        } else if date > currentDate {
            return currentDate
        }
        return date
    }
    
    private func getDisabledMonths() -> [String]? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        guard let yearLabelText = yearLabel.text,
            let yearDate = dateFormatter.date(from: yearLabelText),
            let yearDatePlusOne = Calendar.current.date(byAdding: DateComponents(year: 1), to: yearDate)
            else { return nil }
        let allMonths = getAllMonthsStrings()
        if yearDate < limitMinimumDate {
            guard let month = Calendar.current.dateComponents([.month], from: limitMinimumDate).month else { return nil }
            let disabledMonths = allMonths.prefix(upTo: month - 1)
            return Array(disabledMonths)
        } else if yearDatePlusOne > currentDate {
            guard let month = Calendar.current.dateComponents([.month], from: currentDate).month else { return nil }
            let disabledMonths = allMonths.suffix(from: month)
            return Array(disabledMonths)
        }
        return nil
    }
    
    private func setAccessibility() {
        self.titleLabel.accessibilityIdentifier = AccessibilityAccountFilter.titleDateFilter
        self.timeSegmentedControl.accessibilityIdentifier = AccessibilityAccountFilter.timeSegmentedControl
        self.startDateTextField.accessibilityIdentifier = AccessibilityAccountFilter.startDateTextField
        self.startDateTextField.setAccessibleIdentifiers(
            titleLabelIdentifier: AccessibilityAccountFilter.titleStartDateTextField,
            fieldIdentifier: AccessibilityAccountFilter.dateStartDateTextField,
            imageIdentifier: AccessibilityAccountFilter.icnStartDateTextField)
        self.endDateTextField.accessibilityIdentifier = AccessibilityAccountFilter.endDateFilter
        self.endDateTextField.setAccessibleIdentifiers(
            titleLabelIdentifier: AccessibilityAccountFilter.titleEndDateTextField,
            fieldIdentifier: AccessibilityAccountFilter.dateEndDateTextField,
            imageIdentifier: AccessibilityAccountFilter.icnEndDateTextField)
        self.yearLabel.accessibilityIdentifier = AccessibilityAccountFilter.yearLabelMonthView
        self.leftArrowImage.accessibilityIdentifier = AccessibilityAccountFilter.leftArrowYearMonthView
        self.rightArrowImage.accessibilityIdentifier = AccessibilityAccountFilter.rightArrowYearMonthView

    }
    
    // MARK: - Public methods
    
    public func getStartEndDates() -> (startDate: Date, endDate: Date) {
        let endDateEndOfDay = Calendar.current.date(byAdding: .day, value: 1, to: endDate.startOfDay())?.addingTimeInterval(-1)
        let startUtcDate = startDate.startOfDay().getUtcDate() ?? startDate
        let endUtcDate = endDateEndOfDay?.getUtcDate() ?? endDate
        return (startUtcDate, endUtcDate)
    }
    
    public func getSelectedIndex() -> Int {
        if isCustomRangeDate {
            return -1
        } else {
            return self.timeSegmentedControl.selectedSegmentIndex
        }
    }
    
    public func addInfoToolTip(_ action: ((UIView) -> Void)?) {
        self.informationImage.image = Assets.image(named: "icnInfoRedLight")
        self.informationImage.isAccessibilityElement = true
        self.informationImage.isHidden = false
        self.informationButton.isHidden = false
        self.informationAction = action
    }
    
    @IBAction func didSelectTooltip(_ sender: UIButton) {
        self.informationAction?(sender)
    }
}

// swiftlint:enable type_body_length
private extension DateFilterView {
    
    @objc func didBeginEditing() {
        previousStartDateBeforeEditing = startDate
        previousEndDateBeforeEditing = endDate
        setMonthViewIsHidden(true)
        changeTimeSegmentedControlColor(isSelected: false, type: nil)
    }
}
