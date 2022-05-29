//
//  DateParser.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 03/07/2019.
//

import Foundation

protocol DateParseable {
    
    /// Returns the formats for every date in your model hierarchy. You have to add `.` if you want to access to properties of not root entity.
    /// Example. Given the current json:
    ///
    /// {
    ///     "date": "15 01 2019"
    ///     "any_object": {
    ///         "date": "July"
    ///     }
    /// }
    ///
    /// In your entity you have to add the following code:
    ///
    /// static var formats: [String: String] {
    ///     return [
    ///         "date": "dd MM yyyy",
    ///         "any_object.date": "MMMM"
    ///     ]
    /// }
    static var formats: [String: String] { get }
}

enum DateParseableError: Error {
    
    case dateFormatError
    
    var localizedDescription: String {
        switch self {
        case .dateFormatError:
            return "The date format is not correct"
        }
    }
}

extension DateParseable {
    
    static func decode(with decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        let noArrayCodingKeys = decoder.codingPath.filter(isNotArray)
        let key = noArrayCodingKeys.map({ $0.stringValue }).joined(separator: ".")
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = formats[key]
        guard let decodedDate = formatter.date(from: dateString) else {
            throw DateParseableError.dateFormatError
        }
        return decodedDate
    }
    
    private static func isNotArray(_ codingKey: CodingKey) -> Bool {
        return !codingKey.stringValue.contains("Index")
    }
}

extension Array: DateParseable where Element: DateParseable {
    
    static var formats: [String: String] {
        return Element.formats
    }
}
