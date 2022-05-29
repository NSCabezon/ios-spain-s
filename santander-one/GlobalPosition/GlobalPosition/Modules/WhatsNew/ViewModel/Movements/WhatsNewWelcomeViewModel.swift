//
//  WhatsNewWelcomeViewModel.swift
//  GlobalPosition
//
//  Created by Laura González on 02/07/2020.
//

import CoreFoundationLib
import UI

enum LoginDateType {
    case today
    case yesterday
    case weekDay
    case otherDay
}

class WhatsNewWelcomeViewModel {
    private var loginDate: Date?
    private var dateSimpleString: String?
    private var dateLongString: String?
    private var dateWeekString: String?
    private let actualDate = Date()
    private var alias: String?
    
    init(loginDate: Date?, dateSimpleString: String?, dateLongString: String?, dateWeekString: String?) {
        self.loginDate = loginDate
        self.dateSimpleString = dateSimpleString
        self.dateLongString = dateLongString
        self.dateWeekString = dateWeekString
    }

    static var emptyModel: WhatsNewWelcomeViewModel {
        return WhatsNewWelcomeViewModel(loginDate: nil, dateSimpleString: "", dateLongString: "", dateWeekString: "")
    }
    
    public func setUserName(userName: String?) {
        self.alias = userName
    }
    
    var loginDateType: LoginDateType? {
        guard let date = loginDate else { return .none }
        if date.isDayInToday() {
            return .today
        } else if Calendar.current.isDateInYesterday(date) {
            return .yesterday
        } else if Calendar.current.isDate(actualDate, equalTo: date, toGranularity: .weekOfYear) {
            return .weekDay
        } else {
            return .otherDay
        }
    }
    
    var lastSessionText: LocalizedStylableText {
        switch loginDateType {
        case .today:
            return localized("whatsNew_label_lastSessionToday", [StringPlaceholder(.value, dateSimpleString ?? "")])
        case .yesterday:
            return localized("whatsNew_label_lastSessionYesterday", [StringPlaceholder(.value, dateSimpleString ?? "")])
        case .weekDay:
            return localized("whatsNew_label_lastSessionDate", [StringPlaceholder(.date, dateWeekString ?? "")])
        case .otherDay:
            return localized("whatsNew_label_lastSessionDate", [StringPlaceholder(.date, dateLongString ?? "")])
        case .none:
            return .empty
        }
    }
    
    var mainTitleText: LocalizedStylableText {
        guard loginDate != nil else { return .empty }
        switch loginDateType {
        case .today, .yesterday, .weekDay:
            return localized("whatsNew_label_whatHasHappened")
        case .otherDay:
            return localized("whatsNew_label_withoutEnteringFrom")
        case .none:
            return .empty
        }
    }
    
    var mainTitleHeight: CGFloat {
        return showSecondaryTitle ? 20.0 : 50.0
    }
    
    var mainTitleFont: UIFont {
        if showSecondaryTitle {
            return UIFont.santander(family: .text, type: .bold, size: 16)
        } else {
            return UIFont.santander(family: .text, type: .regular, size: 16)
        }
    }
    
    var secondaryTitleHeight: CGFloat {
        return showSecondaryTitle ? 45.0 : 0.0
    }
    
    var showSecondaryTitle: Bool {
        guard loginDate != nil else { return false }
        switch loginDateType {
        case .today, .yesterday, .weekDay, .none:
            return false
        case .otherDay:
            return true
        }
    }
    
    var emptyViewText: LocalizedStylableText {
        guard let date = loginDate else {
            guard let alias = self.alias?.camelCasedString else {
                return LocalizedStylableText.empty
            }
            let namePlaceHolder = StringPlaceholder(.name, alias)
            return WhatsNewCommonTexts.localizableTextForElement(.emptyViewDays(.singular), placeHolder: [namePlaceHolder])
        }
        let daysFromLastConnection = actualDate.totalDays(from: date)
        guard let alias = self.alias?.camelCasedString else {
            return LocalizedStylableText.empty
        }
        let namePlaceHolder = StringPlaceholder(.name, alias)
        if daysFromLastConnection > actualDate.numberOfDaysInMonth() { // months
            let months: Int = daysFromLastConnection / actualDate.numberOfDaysInMonth()
            let monthPlaceholder = StringPlaceholder(.value, String(months))
            return WhatsNewCommonTexts.localizableTextForElement(.emptyViewMonths(.plural), placeHolder: [namePlaceHolder, monthPlaceholder])
        } else if daysFromLastConnection == actualDate.numberOfDaysInMonth() { // 1 month
            return WhatsNewCommonTexts.localizableTextForElement(.emptyViewMonths(.singular), placeHolder: [namePlaceHolder])
        } else if daysFromLastConnection > 1 && daysFromLastConnection < actualDate.numberOfDaysInMonth() { // days
            let daysPlaceHolder = StringPlaceholder(.value, String(daysFromLastConnection))
            return WhatsNewCommonTexts.localizableTextForElement(.emptyViewDays(.plural), placeHolder: [namePlaceHolder, daysPlaceHolder])
        } else if daysFromLastConnection <= 1 { // 1day
            return WhatsNewCommonTexts.localizableTextForElement(.emptyViewDays(.singular), placeHolder: [namePlaceHolder])
        }
        return WhatsNewCommonTexts.localizableTextForElement(.emptyViewDays(.singular), placeHolder: [namePlaceHolder])
    }
}

public enum WhatsNewTextElements {
    case emptyViewDays(GrammarNumber)
    case emptyViewMonths(GrammarNumber)
}

public struct WhatsNewCommonTexts {
    static func localizableTextForElement(_ element: WhatsNewTextElements, placeHolder: [StringPlaceholder]) -> LocalizedStylableText {
        switch element {
        case .emptyViewDays(let grammar):
            return localizedFor(grammar == .singular ? "whatsNew_emptyView_days_one" : "whatsNew_emptyView_days_other", placeHolder: placeHolder)
        case .emptyViewMonths(let grammar):
            return localizedFor(grammar == .singular ? "whatsNew_emptyView_months_one" : "whatsNew_emptyView_months_other", placeHolder: placeHolder)
        }
    }
    
    private static func localizedFor(_ key: String, placeHolder: [StringPlaceholder]?) -> LocalizedStylableText {
        if let optionalPlaceHolder = placeHolder {
            return localized(key, optionalPlaceHolder)
        } else {
            return localized(key)
        }
    }
}
