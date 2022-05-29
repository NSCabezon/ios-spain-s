//
//  DateDecorator.swift
//  Commons
//
//  Created by Carlos Gutiérrez Casado on 02/04/2020.
//

import Foundation

public class DateDecorator {
    let date: Date
    
    public init(_ date: Date) {
        self.date = date
    }
    
    public func setDateFormatter(_ filtered: Bool) -> LocalizedStylableText {
        let dateFormat = filtered ? TimeFormat.d_MMM_yyyy : TimeFormat.d_MMM
        let dateMonth = dateToStringFromCurrentLocale(date: date, outputFormat: dateFormat)?.uppercased() ?? ""
        let weekDay = dateToStringFromCurrentLocale(date: date, outputFormat: .eeee) ?? ""
        let stringWeekDay = weekDay.prefix(1).uppercased() + weekDay.dropFirst()
        let dateString = localized("generic_label_listDate", [
            StringPlaceholder(.date, dateMonth),
            StringPlaceholder(.value, stringWeekDay.components(separatedBy: "-").first ?? "")
        ])
        if date.isDayInToday() {
            return localized("product_label_todayTransaction", [StringPlaceholder(.date, dateString.text)])
        } else {
            return dateString
        }
    }
        
    public func setDateFormatterComplete(_ filtered: Bool) -> LocalizedStylableText {
        let dateFormat = filtered ? TimeFormat.d_MMM_yyyy : TimeFormat.d_MMM
        let dateMonth = dateToStringFromCurrentLocale(date: date, outputFormat: dateFormat)?.uppercased() ?? ""
        let weekDay = dateToStringFromCurrentLocale(date: date, outputFormat: .eeee) ?? ""
        let stringWeekDay = weekDay.prefix(1).uppercased() + weekDay.dropFirst()
        let dateString = localized("generic_label_listDate", [
            StringPlaceholder(.date, dateMonth),
            StringPlaceholder(.value, stringWeekDay.components(separatedBy: "-").first ?? "")
        ])
        if date.isDayInToday() {
            return localized("product_label_todayTransaction", [StringPlaceholder(.date, dateString.text)])
        } else if date.isTomorrow() {
            return localized("product_label_tomorrowTransaction", [StringPlaceholder(.date, dateString.text)])
        } else if date.isAfterTomorrow() {
            return localized("product_label_nextTransaction", [StringPlaceholder(.date, dateString.text)])
        } else {
            return dateString
        }
    }
    
    public func setDateFormatterTransactions() -> LocalizedStylableText {
        let dateFormat = TimeFormat.d_MMMM_YYYY
        let dateMonth = dateToStringFromCurrentLocale(date: date, outputFormat: dateFormat) ?? ""
        let weekDay = dateToStringFromCurrentLocale(date: date, outputFormat: .eeee) ?? ""
        let stringWeekDay = weekDay.prefix(1).uppercased() + weekDay.dropFirst()
        let dateString: LocalizedStylableText = localized("\(stringWeekDay), \(dateMonth)")
        if date.isDayInToday() {
            return localized("generic_label_todayTransaction", [StringPlaceholder(.date, dateString.text)])
        } else if date.isTomorrow() {
            return localized("product_label_tomorrowTransaction", [StringPlaceholder(.date, dateString.text)])
        } else if date.isAfterTomorrow() {
            return localized("product_label_nextTransaction", [StringPlaceholder(.date, dateString.text)])
        } else {
            return dateString
        }
    }
}
