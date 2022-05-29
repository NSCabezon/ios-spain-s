//
//  TimeManagerGlobal.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 28/01/2020.
//

import Foundation

public final class TimeManagerGlobal {
    
    public static var shared: TimeManagerGlobal = TimeManagerGlobal()
    private var dependenciesResolver: DependenciesResolver?
    private lazy var timeManager: TimeManager? = {
      return dependenciesResolver?.resolve(for: TimeManager.self)
    }()

    public func setup(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    fileprivate func fromString(input: String?, inputFormat: String) -> Date? {
        return timeManager?.fromString(input: input, inputFormat: inputFormat)
    }
    
    fileprivate func fromString(input: String?, inputFormat: TimeFormat) -> Date? {
        return timeManager?.fromString(input: input, inputFormat: inputFormat)
    }
    
    fileprivate func fromString(input: String?, inputFormat: TimeFormat, timeZone: TimeManagerTimeZone) -> Date? {
       return timeManager?.fromString(input: input, inputFormat: inputFormat, timeZone: timeZone)
    }
    
    fileprivate func toString(date: Date?, outputFormat: TimeFormat, timeZone: TimeManagerTimeZone) -> String? {
        return timeManager?.toString(date: date, outputFormat: outputFormat, timeZone: timeZone)
    }
    
    fileprivate func toString(input: String?, inputFormat: TimeFormat, outputFormat: TimeFormat) -> String? {
        return timeManager?.toString(input: input, inputFormat: inputFormat, outputFormat: outputFormat)
    }
    
    fileprivate func toString(date: Date?, outputFormat: TimeFormat) -> String? {
        return timeManager?.toString(date: date, outputFormat: outputFormat)
    }
    
    fileprivate func toStringFromCurrentLocale(date: Date?, outputFormat: TimeFormat) -> String? {
        return timeManager?.toStringFromCurrentLocale(date: date, outputFormat: outputFormat)
    }
    
    fileprivate func getCurrentLocaleDate(inputDate: Date?) -> Date? {
        return timeManager?.getCurrentLocaleDate(inputDate: inputDate)
    }
}

public func dateFromString(input: String?, inputFormat: String) -> Date? {
    return TimeManagerGlobal.shared.fromString(input: input, inputFormat: inputFormat)
}

public func dateFromString(input: String?, inputFormat: TimeFormat) -> Date? {
    return TimeManagerGlobal.shared.fromString(input: input, inputFormat: inputFormat)
}

public func dateFromString(input: String?, inputFormat: TimeFormat, timeZone: TimeManagerTimeZone) -> Date? {
   return TimeManagerGlobal.shared.fromString(input: input, inputFormat: inputFormat, timeZone: timeZone)
}

public func dateToString(date: Date?, outputFormat: TimeFormat, timeZone: TimeManagerTimeZone) -> String? {
    return TimeManagerGlobal.shared.toString(date: date, outputFormat: outputFormat, timeZone: timeZone)
}

public func dateToString(input: String?, inputFormat: TimeFormat, outputFormat: TimeFormat) -> String? {
    return TimeManagerGlobal.shared.toString(input: input, inputFormat: inputFormat, outputFormat: outputFormat)
}

public func dateToString(date: Date?, outputFormat: TimeFormat) -> String? {
    return TimeManagerGlobal.shared.toString(date: date, outputFormat: outputFormat)
}

public func dateToStringFromCurrentLocale(date: Date?, outputFormat: TimeFormat) -> String? {
    return TimeManagerGlobal.shared.toStringFromCurrentLocale(date: date, outputFormat: outputFormat)
}

public func dateGetCurrentLocaleDate(inputDate: Date?) -> Date? {
    return TimeManagerGlobal.shared.getCurrentLocaleDate(inputDate: inputDate)
}
