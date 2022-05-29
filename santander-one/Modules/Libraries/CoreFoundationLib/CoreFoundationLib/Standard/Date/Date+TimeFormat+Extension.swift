//
//  Date+Extension.swift
//  CoreFoundationLib
//
//  Created by Juan Carlos López Robles on 12/23/21.
//

import Foundation

public extension Date  {
     enum TimeFormat: String {
        case YYYYMMDD = "yyyy-MM-dd"
        case YYYYMMDD_HHmmss = "yyyy-MM-dd HH:mm:ss"
        case YYYYMMDD_HHmmssSSS = "yyyy-MM-dd HH:mm:ss:SSS"
        case YYYYMMDD_HHmmssSSSZ = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        case YYYYMMDD_HHmmssT = "yyyy-MM-dd'T'HH:mm:ssZ"
        case YYYYMMDD_HHmmssSSST = "yyyy-MM-dd'T'HH:mm:ss:SSSZ"
        case YYYYMMDD_T_HHmmss = "yyyy-MM-dd'T'HH:mm:ss"
        case YYYYMMDD_T_HHmmssSSS = "yyyy-MM-dd'T'HH:mm:ssSSS"
        case DDMMYYYY = "dd-MM-yyyy"
        case DDMMYYYY_HHmmss = "dd-MM-yyyy HH:mm:ss"
        case DDMMYYYY_HHmmssSSSSSS = "dd-MM-yyyy HH:mm:ss:SSSSSS"
        case DDMMMYYYY_HHmmss = "dd-MMM-yyyy HH:mm:ss"
        case HHmm = "HH:mm"
        case HHmmss = "HH:mm:ss"
        case HHmmssZ = "HH:mm:ssZ"
        case yyyyMM = "yyyyMM"
        case MMyyyy = "MMyyyy"
        case yyyyMMdd_T_HHmmssSSSz = "yyyyMMdd'T'HHmmssSSSZ"
    }

    func toString(_ format: TimeFormat) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: self)
    }
    
    func toString(_ format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: self)
    }
    
    func parse(_ string: String, format: TimeFormat) -> Date?{
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.date(from: string)
    }
    
    func parse(_ string: String, format: String) -> Date?{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.date(from: string)
    }
    
    func toString(_ format: String, locale: Locale) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = locale
        return formatter.string(from: self)
    }
}
