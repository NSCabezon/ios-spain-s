//
//  MonthView.swift
//  UI
//
//  Created by David Gálvez Alonso on 12/11/2020.
//

import CoreFoundationLib

public protocol MonthViewDelegate: AnyObject {
    func didSelectedDates(_ startDate: Date?, endDate: Date?)
    func didSelectMonth(_ nameMonth: String, nameYear: String, differenceBetweenMonths: Int)
}

final public class MonthView: UIDesignableView {
    
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var monthStackView: MultiselectionStackView!
    @IBOutlet private weak var leftArrowImage: UIImageView!
    @IBOutlet private weak var rightArrowImage: UIImageView!
    @IBOutlet private weak var yearLabel: UILabel!
    
    private var currentDate = Date()
    private var limitMinimumDate = Calendar.current.date(byAdding: DateComponents(month: -25), to: Date()) ?? Date()
    private var selectedYear: String?
    private var startDate: Date?
    private var endDate: Date?
    
    public var selectedMonth: String = ""
    public weak var delegate: MonthViewDelegate?

    override public func commonInit() {
        super.commonInit()
        configureView()
        configureHeaderView()
        configureMonthView()
    }
    
    public func setLimitMinimumDate(_ months: Int, currentDate: Date = Date()) {
        self.limitMinimumDate = Calendar.current.date(byAdding: DateComponents(month: -months), to: Date()) ?? Date()
        self.currentDate = currentDate
        configureCurrentDate()
    }
}

private extension MonthView {
    
    func configureView() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightSkyBlue.cgColor
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
    
    func configureHeaderView() {
        headerView.backgroundColor = .silverLight
        leftArrowImage.image = Assets.image(named: "icnWhiteBoxBack")
        leftArrowImage.isUserInteractionEnabled = true
        leftArrowImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(arrowDidPressed(_:))))
        rightArrowImage.image = Assets.image(named: "icnWhiteBoxNext")
        rightArrowImage.isUserInteractionEnabled = true
        rightArrowImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(arrowDidPressed(_:))))
        yearLabel.font = UIFont.santander(family: .text, type: .bold, size: 20)
        yearLabel.textColor = .lisboaGray
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        yearLabel.text = dateFormatter.string(from: currentDate)
        setAccessibilityIdentifiers()
    }
    
    func configureCurrentDate() {
        let allMonths = getAllMonthsStrings()
        guard let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: currentDate))),
            let monthIndex = Calendar.current.dateComponents([.month], from: startOfMonth).month,
            allMonths.indices.contains(monthIndex - 1)
            else { return }
        selectedMonth = allMonths[monthIndex - 1]
        reloadMonthStackView(allMonths[monthIndex - 1])
    }
    
    func configureMonthView() {
        let allMonths = getAllMonthsStrings()
        let disbledMonths = getDisabledMonths()
        let accessibilityMonths = getAccessibilityIdentifiers()
        monthStackView?.addValues(allMonths.map({ (month) in
            ValueOptionType(value: month, displayableValue: month.camelCasedString, isHighlighted: false, action: { [weak self] in
                self?.setMonth(month)
                }, isDisabled: disbledMonths?.contains(month), accessibilityIdentifier: accessibilityMonths[month] ?? "")
        }))
    }
    
    func getAllMonthsStrings() -> [String] {
        let allMonths = ["generic_label_january", "generic_label_february", "generic_label_march", "generic_label_april", "generic_label_may", "generic_label_june", "generic_label_july", "generic_label_august", "generic_label_september", "generic_label_october", "generic_label_november", "generic_label_december"]
        return allMonths.map { localized($0) }
    }
    
    func getDisabledMonths() -> [String]? {
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
    
    func getAccessibilityIdentifiers() -> [String: String] {
        let months = getAllMonthsStrings()
        let monthsAccessibilityIds = [AccessibilityTransactionsSearch.btnJanuary.rawValue, AccessibilityTransactionsSearch.btnFebruary.rawValue, AccessibilityTransactionsSearch.btnMarch.rawValue, AccessibilityTransactionsSearch.btnApply.rawValue, AccessibilityTransactionsSearch.btnMay.rawValue, AccessibilityTransactionsSearch.btnJune.rawValue, AccessibilityTransactionsSearch.btnJuly.rawValue, AccessibilityTransactionsSearch.btnAugust.rawValue, AccessibilityTransactionsSearch.btnSeptember.rawValue, AccessibilityTransactionsSearch.btnOctober.rawValue, AccessibilityTransactionsSearch.btnNovember.rawValue, AccessibilityTransactionsSearch.btnDecember.rawValue]
        let monthsJoined = months.enumerated().reduce([String: String]()) { (element, element2) -> [String: String] in
            var element = element
            element[element2.element] = monthsAccessibilityIds[element2.offset]
            return element
        }
        return monthsJoined
    }
    
    func setMonth(_ month: String) {
        selectedYear = yearLabel.text
        selectedMonth = month
        reloadMonthStackView(month)
        setMonthDates(month)
        delegate?.didSelectedDates(startDate, endDate: endDate)
    }
    
    func reloadMonthStackView(_ month: String = "") {
        let disbledMonths = getDisabledMonths()
        monthStackView?.reloadValues(month, disabledOptions: disbledMonths)
    }
    
    func setMonthDates(_ month: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let allMonths = getAllMonthsStrings()
        guard let monthIndex = allMonths.firstIndex(of: month),
            let yearLabelText = yearLabel.text,
            let yearDate = dateFormatter.date(from: yearLabelText),
            let currentSelectedDate = Calendar.current.date(byAdding: DateComponents(month: monthIndex), to: yearDate)
            else { return  }
        setStartEndDates(date: currentSelectedDate)
        let differenceBetweenMonths = Calendar.current.dateComponents([.month], from: currentSelectedDate, to: currentDate).month ?? 0
        delegate?.didSelectMonth(month, nameYear: yearLabelText, differenceBetweenMonths: differenceBetweenMonths)
    }
    
    @objc func arrowDidPressed(_ sender: UITapGestureRecognizer) {
        let value = sender.view == rightArrowImage ? 1 : -1
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
        let month = Calendar.current.isDate(modifiedDate, equalTo: endDate ?? Date(), toGranularity: .year) ? selectedMonth : ""
        reloadMonthStackView(month)
    }
    
    func setStartEndDates(date: Date) {
        guard let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: date))),
            let endOfMonth = Calendar.current.date(byAdding: DateComponents(month: 1, second: -1), to: startOfMonth)
            else { return }
        startDate = startOfMonth
        endDate = endOfMonth
    }
    
    func setAccessibilityIdentifiers() {
        yearLabel.accessibilityIdentifier = "monthViewYearLabel"
    }
}
