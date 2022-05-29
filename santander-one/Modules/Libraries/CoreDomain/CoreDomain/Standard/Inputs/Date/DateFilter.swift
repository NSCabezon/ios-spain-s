import Foundation

public class DateFilter: Codable {

    public var fromDateModel: DateModel?
    public var toDateModel: DateModel?
    
    public init() {}
    
    public init(from fromDate: Date?, to toDate: Date?) {
        if let fromDate = fromDate {
            self.fromDateModel = DateModel(date: fromDate)
        }
        
        if let toDate = toDate {
            self.toDateModel = DateModel(date: toDate)
        }
    }

    public class func getDateFilterFor(numberOfYears: Int) -> DateFilter {
        let dateFilter = DateFilter()

        var dateComponent = DateComponents()
        dateComponent.year = numberOfYears

        let date = Date()
        dateFilter.fromDateModel = DateModel(date: Calendar.current.date(byAdding: dateComponent, to: date) ?? date)
        dateFilter.toDateModel = DateModel(date: date)

        return dateFilter
    }
    
    public class func getDateFilterFor(numberOfDays: Int) -> DateFilter {
        let dateFilter = DateFilter()
        var dateComponent = DateComponents()
        dateComponent.day = numberOfDays
        let date = Date()
        dateFilter.fromDateModel = DateModel(date: Calendar.current.date(byAdding: dateComponent, to: date) ?? date)
        dateFilter.toDateModel = DateModel(date: date)
        return dateFilter
    }
    
    public class func createSubtractingMonths(months: Int) -> DateFilter {
        let dateFilter = DateFilter.getDateFilterFor(numberOfYears: 0)
        var dateComponent = DateComponents()
        dateComponent.month = -months
        dateFilter.fromDateModel = DateModel(date: Calendar.current.date(byAdding: dateComponent, to: Date()) ?? Date())
        dateFilter.toDateModel = DateModel(date: Date())
        return dateFilter
    }

    public var string: String {
        var fromString = "from="
        var toString = "to="
        if let fromDateModel = fromDateModel {
            fromString += fromDateModel.string
        }
        if let toDateModel = toDateModel {
            toString += toDateModel.string
        }
        return fromString + toString
    }
    
    public var stringQuery: String {
        var fromString = "from_date="
        var toString = "to_date="
        if let fromDateModel = fromDateModel {
            fromString += fromDateModel.stringReverse + "T000000000-0000&"
        }
        if let toDateModel = toDateModel {
            toString += toDateModel.stringReverse + "T000000000-0000&"
        }
        return fromString + toString
    }
}
