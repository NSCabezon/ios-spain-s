//
//  LastBillFilterTagAdapter.swift
//  Bills
//
//  Created by Carlos Monfort Gómez on 23/04/2020.
//

import Foundation
import CoreFoundationLib
import UI

class LastBillFilterTagAdapter {
    
    private var filter: BillFilter

    init(_ filter: BillFilter) {
        self.filter = filter
    }
    
    func getNewFilter(from tagsRemaining: [TagMetaData]) -> BillFilter {
        let remainingTags = Set(tagsRemaining)
        let allTags = Set(getTags())
        let removed = allTags
            .symmetricDifference(remainingTags)
            .filter({ $0.identifier != "generic_button_deleteFilters" })
            .first
        switch removed?.identifier {
        case BillTagMetaDataBuilder.Constants.accountNumber?:
            self.filter = BillFilter(removingAccountWithBillFilter: self.filter)
        case BillTagMetaDataBuilder.Constants.billStatus?:
            self.filter = BillFilter(removingStatusWithBillFilter: self.filter)
        case BillTagMetaDataBuilder.Constants.dateRange?:
            self.filter = BillFilter(removingDateRangeWithBillFilter: self.filter)
        default:
            break
        }
        return self.filter
    }
    
    func getTags() -> [TagMetaData] {
        let builder = BillTagMetaDataBuilder(filter: self.filter)
        builder.addAccount()
        builder.addDateRange()
        builder.addBillStatus()
        return builder.build()
    }
}

private class BillTagMetaDataBuilder {
    
    private var tags: [TagMetaData] = []
    private let filter: BillFilter
    
    struct Constants {
        static let accountNumber = "AccountNumber"
        static let billStatus = "BillStatus"
        static let dateRange = "DateRange"
    }
    
    init(filter: BillFilter) {
        self.filter = filter
    }
    
    func addAccount() {
        guard let account = self.filter.account else { return }
        self.tags.append(TagMetaData(withLocalized: .plain(text: account.alias ?? ""), identifier: Constants.accountNumber, accessibilityId: AccesibilityBills.LastBillFilterTagView.filterAccount))
    }
    
    func addBillStatus() {
        guard self.filter.billStatus != .unknown else { return }
        self.tags.append(TagMetaData(withLocalized: localized(self.filter.billStatus.description), identifier: Constants.billStatus, accessibilityId: AccesibilityBills.LastBillFilterTagView.filterStatus))
    }
    
    func addDateRange() {
        switch self.filter.dateRange {
        case .range(startDate: let startDate, endDate: let endDate, index: _):
            let startDate = dateToString(date: startDate, outputFormat: .d_MMM_yyyy) ?? ""
            let endDate = dateToString(date: endDate, outputFormat: .d_MMM_yyyy) ?? ""
            let tag = TagMetaData(
                withLocalized: localized("search_text_sinceUntilDate", [StringPlaceholder(.date, startDate), StringPlaceholder(.date, endDate)]),
                identifier: Constants.dateRange,
                accessibilityId: AccesibilityBills.LastBillFilterTagView.filterDate
            )
            self.tags.append(tag)
        case .unknown:
            break
        }
    }
    
    func build() -> [TagMetaData] {
        return self.tags
    }
}

private extension LastBillFilterTagAdapter {
    
    private func getDefaultDateRange() -> BillFilter.DateRange {
        return .unknown
    }
}
