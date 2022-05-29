//
//  FinanciableTransactionsDatesProtocol.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 16/11/2020.
//


public protocol FinanciableTransactionsDatesProtocol {
    var maxDays: Int { get }
    var startDate: Date? { get }
    var endDate: Date? { get }
    func getSearchedDates() -> [Date]
}

public extension FinanciableTransactionsDatesProtocol {
    var maxDays: Int {
        return 60
    }
    
    var today: Date {
        Date()
    }
    
    var startDate: Date? {
        let result = today.startOfDay().getUtcDate()?.addDay(days: -self.maxDays)
        return result
    }
    
    var endDate: Date? {
        today.startOfDay()
    }
    
    func getSearchedDates() -> [Date] {
        var dateArray = [Date]()
        guard let optionalStartDate = startDate, let optionalEndDate = endDate else {
            return dateArray
        }
        dateArray.append(optionalStartDate)
        dateArray.append(optionalStartDate.addMonth(months: 1))
        dateArray.append(optionalEndDate)
        return dateArray
    }
}
