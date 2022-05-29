//
//  TimePeriodSelectorViewModel.swift
//  Menu
//
//  Created by Mario Rosales Maillo on 30/6/21.
//

import CoreFoundationLib

struct TimePeriodSelectorViewModel {
    
    let dependenciesResolver: DependenciesResolver
    
    init(resolver: DependenciesResolver) {
        self.dependenciesResolver = resolver
    }
    
    public func getChosenTemporalViewText() -> LocalizedStylableText {
        return localized("analysis_label_chosenTemporalView")
    }
    
    public func getToolbarTitleKey() -> String {
        return "toolbar_title_chooseTemporaryView"
    }
    
    public func getSaveText() -> String {
        return localized("generic_button_save").text
    }
    
    public func getDateStart() -> String {
        return localized("search_label_startDate").text
    }
    
    public func getDateEnd() -> String {
        return localized("search_label_endDate").text
    }
    
    public func getAcceptText() -> String {
        return localized("generic_button_accept").text
    }
    
    public func getCancelText() -> String {
        return localized("generic_button_cancel").text
    }
    
    public func getPeriodText(for period: TimePeriodType) -> LocalizedStylableText {
        return localized(getKey(for: period))
    }
    
    public func getKey(for period: TimePeriodType) -> String {
        switch period {
        case .monthly:
            return "analysis_tab_monthlyView"
        case .annual:
            return "analysis_tab_annualView"
        case .quarterly:
            return "analysis_tab_quarterlyView"
        case .custom:
            return "analysis_tab_customPeriodView"
        }
    }
    
    public func getCalendarImageKey() -> String {
        return "analysisBtnCalendar"
    }
    
    public func getImageKey(for period: TimePeriodType, isSelected: Bool = false) -> String {
        switch period {
        case .custom:
            return isSelected ? "icnGreenCalendarDay" : "icnGrayCalendarDay"
        default:
            return ""
        }
    }
    
    public func dateFormat(_ date: Date) -> NSMutableAttributedString? {
        let aString = NSMutableAttributedString()
        let timeManager = self.dependenciesResolver.resolve(for: TimeManager.self)
        guard let monthString = timeManager.toString(date: date, outputFormat: .MMM) else {
            return aString
        }
        guard let yearString = timeManager.toString(date: date, outputFormat: .yyyy) else {
            return aString
        }
        guard let dayString = timeManager.toString(date: date, outputFormat: .d) else {
            return aString
        }

        let slash = NSAttributedString(string: "/", attributes: [.foregroundColor: UIColor.mediumSkyGray])
        aString.append(NSMutableAttributedString(string: dayString,
                                                          attributes: [.foregroundColor: UIColor.lisboaGray]))
        aString.append(slash)
        aString.append(NSMutableAttributedString(string: monthString,
                                                          attributes: [.foregroundColor: UIColor.lisboaGray]))
        aString.append(slash)
        aString.append(NSMutableAttributedString(string: yearString,
                                                          attributes: [.foregroundColor: UIColor.lisboaGray]))
        return aString
    }
}
