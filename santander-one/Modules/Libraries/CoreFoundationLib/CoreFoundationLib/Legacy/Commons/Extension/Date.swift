extension Date { 
    public func formatedLocalizedHeader() -> LocalizedStylableText {
        var dateString: String = ""
        if let formmatedWithUpperCase = dateToString(date: self, outputFormat: .d_MMM)?.uppercased(),
            let weekDayString = dateToString(date: self, outputFormat: .eeee)?.camelCasedString {
            dateString = formmatedWithUpperCase
            dateString.append(" | \(weekDayString)")
        } else {
            return LocalizedStylableText.empty
        }
        if self.isDayInToday() {
            return localized("product_label_todayTransaction", [StringPlaceholder(.date, dateString)])
        } else {
            return LocalizedStylableText(text: dateString, styles: nil)
        }
    }
    
    public func operativeDetailDate() -> String? {
        return dateToString(date: self, outputFormat: .dd_MMM_yyyy)
    }
    
    public var timeRemainingInbox: LocalizedStylableText {
        guard let days = Calendar.current.dateComponents([.day], from: Date(), to: self).day else {
            return LocalizedStylableText(text: "", styles: nil)
        }
        if days == 0 {
            return LocalizedStylableText(text: localized("contracts_label_rememberToday"), styles: nil)
        } else if (1..<3).contains(days) {
            return localized("contracts_label_rememberHours", [StringPlaceholder(.number, "\(days * 24)")])
        } else {
            return localized("contracts_label_rememberDays", [StringPlaceholder(.number, "\(days)")])
        }
    }
}