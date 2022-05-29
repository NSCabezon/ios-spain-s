//
//  DateParseable.swift
//  Commons
//
//  Created by José Carlos Estela Anguita on 25/02/2020.
//

import Foundation

public protocol DateParseable {
    
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

public enum DateParseableError: Error {
    
    case dateFormatError
    
    var localizedDescription: String {
        switch self {
        case .dateFormatError:
            return "The date format is not correct"
        }
    }
}

extension DateParseable {
    
    public static func decode(with decoder: Decoder) throws -> Date {
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
    
    public static func encoding(date: Date, encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let noArrayCodingKeys = encoder.codingPath.filter(isNotArray)
        let key = noArrayCodingKeys.map({ $0.stringValue }).joined(separator: ".")
        let formatter = DateFormatter()
        formatter.dateFormat = formats[key]
        try container.encode(formatter.string(from: date))
    }
    
    private static func isNotArray(_ codingKey: CodingKey) -> Bool {
        return !codingKey.stringValue.contains("Index")
    }
}

extension Array: DateParseable where Element: DateParseable {
    
    public static var formats: [String: String] {
        return Element.formats
    }
}
