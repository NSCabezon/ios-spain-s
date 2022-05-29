//
//  FilterViewModel.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/20/20.
//

import Foundation
import CoreFoundationLib

class FilterViewModel {
    let accountFilter: FilterElement<AccountEntity?, String>
    let dateFilter: FilterElement<Int, BillFilter.DateRange>
    let billStateFilter: FilterElement<[String], Int>

    init(filter: BillFilter) {
        self.accountFilter = FilterElement(
            name: localized("search_select_account"),
            value: filter.account,
            selection: filter.account?.alias ??
                localized("search_label_selectAccount")
        )
        
        self.dateFilter = FilterElement(
            name: "search_tab_last60Days",
            value: -60,
            selection: filter.dateRange
        )
        
        let billStatusKeys = LastBillStatusKeys(billStatus: filter.billStatus)
        self.billStateFilter = FilterElement(
            name: localized("search_label_conditionOfReceipt"),
            value: billStatusKeys.allValues(),
            selection: billStatusKeys.selectedItem())
    }
}
