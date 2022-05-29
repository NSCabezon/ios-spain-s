//
//  TransmitterGroupViewModel.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 3/16/20.
//

import Foundation
import CoreFoundationLib

enum BillElementType<T> {
    case header
    case element(T)
    case footer
}

final class TransmitterGroupViewModel {
    private let billGroup: (key: String, value: [LastBillViewModel])
    private let header = 0
    let bills: [LastBillViewModel]
    var isExpanded: Bool = false
    
    init(group: (key: String, value: [LastBillViewModel])) {
        self.billGroup = group
        self.bills = self.billGroup.value
            .sorted(by: { $0.expirationDate > $1.expirationDate })
    }
    
    var name: String {
        return billGroup.key
    }
    
    var dateLocalized: LocalizedStylableText {
        return localized("receiptsAndTaxes_label_lastReceipt",
                         [StringPlaceholder(.date, lastBill.dateString.lowercased())])
    }
    
    var amount: NSAttributedString? {
        return self.lastBill.amountAttributedText
    }
    
    var accountNumber: String {
        return self.lastBill.accountNumber
    }
    
    var billNumberLocalized: LocalizedStylableText {
        let localizeKey = self.bills.count > 1 ?
            "receiptsAndTaxes_text_receipts_other" :
            "receiptsAndTaxes_text_receipts_one"
        return localized(localizeKey, [StringPlaceholder(.number, String(bills.count))])
    }
  
    private var lastBill: LastBillViewModel {
        return bills[0]
    }
    
    var numberOfElements: Int {
        guard self.isExpanded else { return 1 }
        return self.bills.count + 2
    }
    
    private var footer: Int {
        return bills.count + 1
    }
    
    func toggle() {
        self.isExpanded = !self.isExpanded
    }
    
    func elementType(at position: Int) -> BillElementType<LastBillViewModel> {
        if position == header {
            return .header
        } else if position == footer {
            return .footer
        } else {
            return .element(self.bills[position - 1])
        }
    }
}
