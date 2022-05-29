//
//  ProductGroupViewModel.swift
//  Account
//
//  Created by Juan Carlos López Robles on 4/2/20.
//

import Foundation
import CoreFoundationLib

final class ProductGroupViewModel {
    private let billGroup: (key: AccountEntity, value: [LastBillViewModel])
    private var bills: [TransmitterGroupViewModel]
    private let header = 0
    var isExpanded: Bool = false
    
    init(group: (key: AccountEntity, value: [LastBillViewModel])) {
        self.billGroup = group
        self.bills = group.value
            .group(by: {$0.name})
            .sorted(by: { $0.key < $1.key })
            .map { TransmitterGroupViewModel(group: $0) }
    }
    
    var name: String? {
        return self.billGroup.key.alias
    }
    
    var accountNumber: String {
        return billGroup.key.getIBANShort
    }
    
    var debitsNumberLocalized: LocalizedStylableText {
        let localizeKey = self.bills.count > 1 ?
            "receiptsAndTaxes_label_debits_other" :
            "receiptsAndTaxes_label_debits_one"
        return localized(localizeKey, [StringPlaceholder(.number, String(bills.count) )])
    }
    
    var numberOfElements: Int {
        guard self.isExpanded else { return 1 }
        return self.bills.count + 2
    }
    
    private var footer: Int {
        return self.bills.count + 1
    }
    
    func toggle() {
        self.isExpanded = !self.isExpanded
    }
    
    func elementType(at position: Int) -> BillElementType<TransmitterGroupViewModel> {
        if position == header {
            return .header
        } else if position == footer {
            return .footer
        } else {
            return .element(self.bills[position - 1])
        }
    }
}
