import Foundation
//
//  TimeManagerMock.swift
//  Loans-Unit-LoansTests
//
//  Created by Jose Carlos Estela Anguita on 15/10/2019.
//

import Foundation
import CoreFoundationLib

public class TimeManagerMock: TimeManager {
    
    public func fromString(input: String?, inputFormat: String) -> Date? {
        Date()
    }

    public func fromString(input: String?, inputFormat: String, timeZone: TimeManagerTimeZone) -> Date? {
        Date()
    }
    
    public init() {}

    public func fromString(input: String?, inputFormat: TimeFormat) -> Date? {
        return Date()
    }

    public func fromString(input: String?, inputFormat: TimeFormat, timeZone: TimeManagerTimeZone) -> Date? {
        return Date()
    }

    public func toString(date: Date?, outputFormat: TimeFormat, timeZone: TimeManagerTimeZone) -> String? {
        return String()
    }

    public func toString(input: String?, inputFormat: TimeFormat, outputFormat: TimeFormat) -> String? {
        return String()
    }

    public func toString(date: Date?, outputFormat: TimeFormat) -> String? {
        return String()
    }

    public func toStringFromCurrentLocale(date: Date?, outputFormat: TimeFormat) -> String? {
        return String()
    }

    public func getCurrentLocaleDate(inputDate: Date?) -> Date? {
        return Date()
    }
}
