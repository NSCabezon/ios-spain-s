//
//  DateFilterEntity.swift
//  Models
//
//  Created by Jose Carlos Estela Anguita on 10/10/2019.
//

import CoreDomain

public class DateFilterEntity: DTOInstantiable {
    
    public static func onMonthLess() -> DateFilterEntity {
        let date = Date()
        return DateFilterEntity(from: Calendar.current.date(byAdding: .month, value: -1, to: date), to: date)
    }
    
    public let dto: DateFilter
    
    public required init(_ dto: DateFilter) {
        self.dto = dto
    }
    
    public static func createSubtractingMonths(months: Int) -> DateFilterEntity {
        let dateFilter = DateFilter.getDateFilterFor(numberOfYears: 0)
        var dateComponent = DateComponents()
        dateComponent.month = -months
        dateFilter.fromDateModel = DateModel(date: Calendar.current.date(byAdding: dateComponent, to: Date())!)
        dateFilter.toDateModel = DateModel(date: Date())
        return DateFilterEntity(dateFilter)
    }
    
    public static func fromOtherDateToCurrentDate(fromDate: Date) -> DateFilterEntity {
        let dateFilter = DateFilter.getDateFilterFor(numberOfYears: 0)
        dateFilter.fromDateModel = DateModel(date: fromDate)
        dateFilter.toDateModel = DateModel(date: Date())
        return DateFilterEntity(dateFilter)
    }
    
    public convenience init(from initialDate: Date?, to endDate: Date?) {
        let dateFilter = DateFilter.getDateFilterFor(numberOfYears: 0)
        if let initialDate = initialDate {
            dateFilter.fromDateModel = DateModel(date: initialDate)
        } else {
            dateFilter.fromDateModel = nil
        }
        
        if let endDate = endDate {
            dateFilter.toDateModel = DateModel(date: endDate)
        } else {
            dateFilter.toDateModel = nil
        }
        self.init(dateFilter)
    }
}
