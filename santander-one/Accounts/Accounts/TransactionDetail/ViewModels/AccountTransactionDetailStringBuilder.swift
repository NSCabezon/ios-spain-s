//
//  AccountTransactionDetailShareableBuilder.swift
//  Account
//
//  Created by Juan Carlos López Robles on 12/16/19.
//

import Foundation
import CoreFoundationLib

final class AccountTransactionDetailStringBuilder {
    private var sharedString: String = ""
    
    func add(description: String?) -> Self {
        guard let description = description else { return self}
        self.sharedString.append(description)
        self.addLineBreak()
        return self
    }
    
    func add(amount: NSAttributedString?) -> Self {
        guard let amount = amount?.string else { return self }
        let value = String(format: "%@ %@", localized("summary_item_quantity"), amount)
        self.sharedString.append(value)
        self.addLineBreak()
        return self
    }
    
    func add(operationDate: String?) -> Self {
        guard let operationDate = operationDate else { return self }
        let value = String(format: "%@ %@", localized("transaction_label_operationDate"), operationDate)
        self.sharedString.append(value)
        self.addLineBreak()
        return self
    }
    
    func add(valueDate: String?) -> Self {
        guard let valueDate = valueDate else { return self }
        let value = String(format: "%@ %@", localized("transaction_label_valueDate"), valueDate)
        self.sharedString.append(value)
        self.addLineBreak()
        return self
    }
    
    func add(info: [(title: String, description: String)]) -> Self {
        info.forEach { sharedString.append("\($0.title) \($0.description)")}
        return self
    }
    
    private func addLineBreak() {
        sharedString.append("\n")
    }
    
    func build() -> String {
        return sharedString
    }
}
