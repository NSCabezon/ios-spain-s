import Foundation

enum BillAndTaxesFilterParametersStatus {
    case applied
    case notApplied
}

struct BillAndTaxesFilterParameters {
    typealias DateRange = (Date?, Date?)
    var account: Account?
    var dateRange: DateRange
    var status: BillAndTaxesStatus
    
    static func defaultSearch(withAccount account: Account? = nil) -> BillAndTaxesFilterParameters {
        return BillAndTaxesFilterParameters(account: account, dateRange: (nil, nil), status: .all)
    }
    
    var selectedDateRange: (Date?, Date?)? {
        return dateRange
    }
    
}
