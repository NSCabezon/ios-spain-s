//
//  DateFormats.swift
//  SANServicesLibrary
//
//  Created by José María Jiménez Pérez on 28/7/21.
//

public extension Date {
    func stringWithDateFormat(_ dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: self)
    }
}
