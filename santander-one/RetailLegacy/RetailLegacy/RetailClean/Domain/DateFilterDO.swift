import SANLegacyLibrary
import CoreDomain
import Foundation

struct DateFilterDO {
    let dto: DateFilter

    static func onMonthLess () -> DateFilterDO {
        return DateFilterDO.createSubtractingMonths(months: 1)
    }
    
    static func createSubtractingMonths(months: Int) -> DateFilterDO {
        let dateFilter = DateFilter.getDateFilterFor(numberOfYears: 0)
        var dateComponent = DateComponents()
        dateComponent.month = -months
        dateFilter.fromDateModel = DateModel(date: Calendar.current.date(byAdding: dateComponent, to: Date())!)
        dateFilter.toDateModel = DateModel(date: Date())
        return DateFilterDO(dto: dateFilter)
    }
    
    static func formDate(_ fromDate: Date?, to toDate: Date?) -> DateFilterDO {
        let dateFilter = DateFilter.getDateFilterFor(numberOfYears: 0)
        if let fromDate = fromDate {
            dateFilter.fromDateModel = DateModel(date: fromDate)
        } else {
            dateFilter.fromDateModel = nil
        }
        
        if let toDate = toDate {
            dateFilter.toDateModel = DateModel(date: toDate)
        } else {
            dateFilter.toDateModel = nil
        }
        
        return DateFilterDO(dto: dateFilter)
    }
    
    static func fromOtherDateToCurrentDate (fromDate: Date) -> DateFilterDO {
        let dateFilter = DateFilter.getDateFilterFor(numberOfYears: 0)
        dateFilter.fromDateModel = DateModel(date: fromDate)
        dateFilter.toDateModel = DateModel(date: Date())
        return DateFilterDO(dto: dateFilter)
    }
    
    func getFromDate() -> Date? {
        return dto.fromDateModel?.date ?? nil
    }
}
