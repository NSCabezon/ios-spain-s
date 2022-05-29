//
//  BillFilter.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/20/20.
//

import Foundation
import CoreFoundationLib

final class BillFilter {

    let account: AccountEntity?
    let billStatus: LastBillStatus
    let dateRange: DateRange
    
    enum DateRange {
        case range(startDate: Date, endDate: Date, index: Int)
        case unknown
        
        init(startDate: Date, endDate: Date, index: Int) {
            self = .range(startDate: startDate, endDate: endDate, index: index)
        }
        
        var startDate: Date? {
            guard case .range(startDate: let startDate, endDate: _, index: _) = self else { return nil }
            return startDate
        }
        
        var endDate: Date? {
            guard case .range(startDate: _, endDate: let endDate, index: _) = self else { return nil }
            return endDate
        }
        
        var index: Int {
            guard case .range(startDate: _, endDate: _, index: let index) = self else { return -1 }
            return index
        }
    }
    
    init(account: AccountEntity?, billStatus: LastBillStatus, dateRange: DateRange) {
        self.account = account
        self.billStatus = billStatus
        self.dateRange = dateRange
    }
    
    init(removingAccountWithBillFilter billFilter: BillFilter) {
        self.account = nil
        self.billStatus = billFilter.billStatus
        self.dateRange = billFilter.dateRange
    }
    
    init(removingStatusWithBillFilter billFilter: BillFilter) {
        self.account = billFilter.account
        self.billStatus = .unknown
        self.dateRange = billFilter.dateRange
    }
    
    init(removingDateRangeWithBillFilter billFilter: BillFilter) {
        self.account = billFilter.account
        self.billStatus = billFilter.billStatus
        self.dateRange = .unknown
    }
}
