//
//  FilterBuilder.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/20/20.
//

import Foundation
import CoreFoundationLib

final class FilterBuilder {
    private var account: AccountEntity?
    private var billStatus: LastBillStatus = .unknown
    private var dateRange = DateRange(startDate: nil, endDate: nil, index: nil)
    
    private struct DateRange {
        
        enum Index: Int {
            case sevenDays = 0
            case thirtyDays = 1
            case sixtyDays = 2
        }
        
        var startDate: Date?
        var endDate: Date?
        var index: Index?
    }
    
    init() {}
    
    init(_ filter: BillFilter) {
        self.account = filter.account
        switch filter.dateRange {
        case .range(startDate: let startDate, endDate: let endDate, index: let index):
            self.dateRange = DateRange(startDate: startDate, endDate: endDate, index: DateRange.Index(rawValue: index))
        case .unknown:
            self.dateRange = DateRange(startDate: nil, endDate: nil, index: nil)
        }
        self.billStatus = filter.billStatus
    }
    
    func addAccount(_ account: AccountEntity) {
        self.account = account
    }
    
    func addBillStatus(_ billStatus: LastBillStatus) {
        self.billStatus = billStatus
    }
    
    func addDateRangeIndex(_ index: Int) {
        self.dateRange.index = DateRange.Index(rawValue: index)
    }
    
    func addStartDate(_ date: Date) {
        self.dateRange.startDate = date
    }
    
    func addEndDate(_ date: Date) {
        self.dateRange.endDate = date
    }
    
    func build() -> BillFilter {
        let range: BillFilter.DateRange = {
            guard let startDate = dateRange.startDate, let endDate = dateRange.endDate else {
                return .unknown
            }
            return .range(startDate: startDate, endDate: endDate, index: dateRange.index?.rawValue ?? -1)
        }()
        return BillFilter(
            account: account,
            billStatus: billStatus,
            dateRange: range
        )
    }
}
