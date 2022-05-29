//
//  PeriodSelectorXibView.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 18/2/22.
//

import UI
import UIKit
import CoreFoundationLib
import OpenCombine
import UIOneComponents
import CoreDomain

enum PeriodSelectorStates: State {
    case didTapChangeDate(PeriodSelectorRepresentable)
}

final class PeriodSelectorView: XibView {
    
    @IBOutlet private weak var leftArrowButton: OneOvalButton!
    @IBOutlet private weak var rightArrowButton: OneOvalButton!
    @IBOutlet private weak var periodLabel: UILabel!
    private var subscriptions = Set<AnyCancellable>()
    private var subject = PassthroughSubject<PeriodSelectorStates, Never>()
    public lazy var publisher: AnyPublisher<PeriodSelectorStates, Never> = {
        return subject.eraseToAnyPublisher()
    }()
    private var timeSelected: TimeSelectorRepresentable?
    private var allPeriods: [PeriodSelectorModel] = []
    private var indexSelected: Int = -1 {
        didSet {
            updateArrows()
            updateInfoView()
            sendDateSelected()
        }
    }
    let minDate = Date(timeIntervalSince1970: 1567296000)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func updateInfo(userDataSelected: UserDataAnalysisAreaRepresentable) {
        self.timeSelected = userDataSelected.timeSelector
        clearPeriods()
        getPeriods()
        if let indexPreSelected = userDataSelected.periodSelector?.indexSelected {
            indexSelected = indexPreSelected
        } else {
            indexSelected = allPeriods.count - 1
        }
    }
    @IBAction func leftArrowDidTapped(_ sender: Any) {
        indexSelected -= 1
    }
    @IBAction func rightArrowDidTapped(_ sender: Any) {
        indexSelected += 1
    }
}

private extension PeriodSelectorView {
    func setupView() {
        periodLabel.backgroundColor = .clear
        periodLabel.font = .typography(fontName: .oneH100Bold)
        periodLabel.textColor = .oneLisboaGray
        leftArrowButton.size = .small
        leftArrowButton.direction = .left
        leftArrowButton.style = .whiteWithTurquoiseTint
        rightArrowButton.size = .small
        rightArrowButton.direction = .right
        rightArrowButton.style = .whiteWithTurquoiseTint
        setAccessibilityIdentifiers()
    }
    
    func updateArrows() {
        if let timeViewSelected = self.timeSelected?.timeViewSelected,
           timeViewSelected == .customized {
            leftArrowButton.isEnabled = false
            rightArrowButton.isEnabled = false
            return
        }
        switch self.indexSelected {
        case 0:
            leftArrowButton.isEnabled = false
            rightArrowButton.isEnabled = true
        case (allPeriods.count - 1):
            leftArrowButton.isEnabled = true
            rightArrowButton.isEnabled = false
        default:
            leftArrowButton.isEnabled = true
            rightArrowButton.isEnabled = true
        }
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
    
    func updateInfoView() {
        guard let timeViewSelected = self.timeSelected?.timeViewSelected else { return }
        switch timeViewSelected {
        case .mounthly:
            periodLabel.text = self.allPeriods[self.indexSelected].getMonthText()
        case .quarterly:
            periodLabel.text = self.allPeriods[self.indexSelected].getQuarterText()
        case .yearly:
            periodLabel.text = self.allPeriods[self.indexSelected].getAnualText()
        case .customized:
            periodLabel.text = self.getCustomDateText()
        }
    }
    
    func sendDateSelected() {
        let startPeriod = self.minDate > allPeriods[indexSelected].startPeriod ? self.minDate : allPeriods[indexSelected].startPeriod
        let endPeriod = Date() < allPeriods[indexSelected].endPeriod ? Date() : allPeriods[indexSelected].endPeriod
        let period = PeriodSelectorModel(startPeriod: startPeriod, endPeriod: endPeriod, indexSelected: indexSelected)
        subject.send(.didTapChangeDate(period))
    }
    
    func clearPeriods() {
        allPeriods.removeAll()
    }
    
    func getPeriods() {
        guard let timeViewSelected = self.timeSelected?.timeViewSelected else { return }
        switch timeViewSelected {
        case .mounthly:
            createMonthPeriods(dates: getMonthAndYearBetween(from: minDate, to: Date()))
        case .quarterly:
            createQuarterPeriods(dates: getMonthAndYearBetween(from: minDate, to: Date()))
        case .yearly:
            createYearPeriods(dates: getMonthAndYearBetween(from: minDate, to: Date()))
        case .customized:
            createCustomPeriod()
        }
    }
    
    func getMonthAndYearBetween(from start: Date, to end: Date) -> [Date] {
        var allDates: [Date] = []
        guard start < end else { return allDates }
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let month = calendar.dateComponents([.month], from: start, to: end).month ?? 0
        for index in 0...month {
            if let date = calendar.date(byAdding: .month, value: index, to: start) {
                allDates.append(date)
            }
        }
        return allDates
    }
    
    func createMonthPeriods(dates: [Date]) {
        for date in dates {
            guard let endOfMonth = date.endOfMonth() else { return }
            let period = PeriodSelectorModel(startPeriod: date.startOfMonth(), endPeriod: endOfMonth, indexSelected: indexSelected)
            self.allPeriods.append(period)
        }
    }
    
    func createQuarterPeriods(dates: [Date]) {
        var quarterPeriods: Set<PeriodSelectorModel> = []
        for date in dates {
            guard let fistDayOfQuarter = date.fistDayOfQuarter, let lastOfQuarter = date.lastDayOfQuarter else { return }
            let period = PeriodSelectorModel(startPeriod: fistDayOfQuarter, endPeriod: lastOfQuarter, indexSelected: indexSelected)
            quarterPeriods.insert(period)
        }
        self.allPeriods = quarterPeriods.sorted { $0.startPeriod < $1.startPeriod }
    }
    
    func createYearPeriods(dates: [Date]) {
        var yearPeriods: Set<PeriodSelectorModel> = []
        for date in dates {
            guard var firstDayOfYear = date.firstDayOfYear, var lastDayOfYear = date.lastDayOfYear else { return }
            let period = PeriodSelectorModel(startPeriod: firstDayOfYear, endPeriod: lastDayOfYear, indexSelected: indexSelected)
            yearPeriods.insert(period)
        }
        self.allPeriods = yearPeriods.sorted { $0.startPeriod < $1.startPeriod }
    }
    
    func createCustomPeriod() {
        guard let startDate = self.timeSelected?.startDateSelected,
              let enDate = self.timeSelected?.endDateSelected else { return }
        let period = PeriodSelectorModel(startPeriod: startDate, endPeriod: enDate, indexSelected: indexSelected)
        self.allPeriods.append(period)
    }
    
    func getCustomDateText() -> String {
        guard let startDate = self.timeSelected?.startDateSelected,
              let enDate = self.timeSelected?.endDateSelected else { return "" }
        let startPeriodText = startDate.toString(format: TimeFormat.dd_MMM_yyyy.rawValue).capitalized
        let endPeriodText = enDate.toString(format: TimeFormat.dd_MMM_yyyy.rawValue).capitalized
        return startPeriodText + " - " + endPeriodText
    }
    
    func setAccessibilityIdentifiers() {
        leftArrowButton.accessibilityIdentifier = AnalysisAreaAccessibility.leftArrowButton
        rightArrowButton.accessibilityIdentifier = AnalysisAreaAccessibility.rightArrowButton
        periodLabel.accessibilityIdentifier = AnalysisAreaAccessibility.labelPeriod
    }
    
    func setAccessibilityInfo() {
        leftArrowButton.accessibilityLabel = localized("voiceover_previewPeriod")
        rightArrowButton.accessibilityLabel = localized("voiceover_nextPeriod")
        if timeSelected?.timeViewSelected == .quarterly {
            periodLabel.accessibilityLabel = allPeriods[indexSelected].getQuarterTimeAccessibilityLabel()
        } else {
            periodLabel.accessibilityLabel = periodLabel.text
        }
        self.accessibilityElements = [leftArrowButton, periodLabel, rightArrowButton].compactMap {$0}
    }
}

extension PeriodSelectorView: AccessibilityCapable {}

struct PeriodSelectorModel: PeriodSelectorRepresentable, Hashable {
    var startPeriod: Date
    var endPeriod: Date
    var indexSelected: Int
    var manager: PeriodTextManager
    
    init(startPeriod: Date, endPeriod: Date, indexSelected: Int) {
        self.startPeriod = startPeriod
        self.endPeriod = endPeriod
        self.indexSelected = indexSelected
        self.manager = PeriodTextManager(startPeriod: startPeriod, endPeriod: endPeriod)
    }
    
    static func == (lhs: PeriodSelectorModel, rhs: PeriodSelectorModel) -> Bool {
        return lhs.startPeriod == rhs.startPeriod && lhs.endPeriod == rhs.endPeriod
    }
    
    func getMonthText() -> String {
        return manager.getMonthText()
    }
    
    func getQuarterText(_ dashFormat: String? = nil) -> String {
        return manager.getQuarterText(dashFormat)
    }
    
    func getQuarterTimeAccessibilityLabel() -> String {
        let startPeriodText = startPeriod.toString(format: TimeFormat.MMMM.rawValue)
        let endPeriodText = endPeriod.toString(format: TimeFormat.MMMM_YYYY.rawValue)
        return "\(startPeriodText), \(endPeriodText)"
    }
    
    func getAnualText() -> String {
        return manager.getAnualText()
    }
}
