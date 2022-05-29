//
//  Date+Extension.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 04/07/2019.
//

import Foundation

enum DateFormat: String {
    case yyyyMMdd
    case MMM
    case ddMMyyyy = "dd/MM/yyyy"
    case ddMMyyyyWithHyphenSeparator = "dd-MM-yyyy"
    case yyyyMMddWithHyphenSeparator = "yyyy-MM-dd"
    case api = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    case MMMyyyy = "MMM yyyy"
    case ddMM = "dd MMM | "
    case EEEE = "EEEE"
}


extension Date {
    
    func getToday() -> String {
        return self.string(format: .ddMM)
            .uppercased() + ( self.string(format: .EEEE)
                                .prefix(1).uppercased() + self.string(format: .EEEE).dropFirst())
    }
    
    func getMonth() -> String {
        let formatter = DateFormatter()
        if let locale = TimeLine.dependencies.configuration?.language {
             formatter.locale = Locale(identifier: locale)
        }
        formatter.dateFormat = "MMM"
        return formatter.string(from: self)
    }
    
    func string(format: DateFormat) -> String {
        let formatter = DateFormatter()
        if let locale = TimeLine.dependencies.configuration?.language {
            formatter.locale = Locale(identifier: locale )
        }
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
}
