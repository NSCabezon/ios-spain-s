//
//  TimeManagerMock.swift
//  Loans-Unit-LoansTests
//
//  Created by Jose Carlos Estela Anguita on 15/10/2019.
//

import Foundation
import CoreFoundationLib

class TimeManagerMock: TimeManager {
    
    func fromString(input: String?, inputFormat: TimeFormat) -> Date? {
        return Date()
    }
    
    func fromString(input: String?, inputFormat: TimeFormat, timeZone: TimeManagerTimeZone) -> Date? {
        return Date()
    }
    
    func toString(date: Date?, outputFormat: TimeFormat, timeZone: TimeManagerTimeZone) -> String? {
        return String()
    }
    
    func toString(input: String?, inputFormat: TimeFormat, outputFormat: TimeFormat) -> String? {
        return String()
    }
    
    func toString(date: Date?, outputFormat: TimeFormat) -> String? {
        return String()
    }
    
    func toStringFromCurrentLocale(date: Date?, outputFormat: TimeFormat) -> String? {
        return String()
    }
    
    func getCurrentLocaleDate(inputDate: Date?) -> Date? {
        return Date()
    }
}
