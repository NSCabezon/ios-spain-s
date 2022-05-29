//
//  CardTransactionDetailStringBuilder.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 12/16/19.
//

import Foundation
import CoreFoundationLib

public final class CardTransactionDetailStringBuilder {
    private var sharedString: String = ""
    
    public init() {}
    
    public func add(description: String?) -> Self {
        guard let description = description else { return self}
        self.sharedString.append(description)
        self.addLineBreak()
        return self
    }
    
    public func add(amount: NSAttributedString?) -> Self {
        guard let amount = amount?.string else { return self }
        let value = String(format: "%@ %@", localized("summary_item_quantity"), amount)
        self.sharedString.append(value)
        self.addLineBreak()
        return self
    }
    
    public func add(operationDate: NSAttributedString?) -> Self {
        guard let operationDate = operationDate?.string else { return self }
        let value = String(format: "%@ %@", localized("transaction_label_operationDate"), operationDate)
        self.sharedString.append(value)
        self.addLineBreak()
        return self
    }
    
    public func add(annotationDate: String?) -> Self {
        guard let annotationDate = annotationDate else { return self }
        let value = String(format: "%@ %@", localized("cardDetail_label_annotationDate"), annotationDate)
        self.sharedString.append(value)
        self.addLineBreak()
        return self
    }
    
    public func add(bankCharge: String?) -> Self {
        guard let bankCharge = bankCharge else { return self }
        let value = String(format: "%@ %@", localized("cardDetail_label_commissions"), bankCharge)
        self.sharedString.append(value)
        return self
    }
    
    public func add(status: String?) -> Self {
        guard let status = status, !status.isEmpty else { return self }
        let value = String(format: "%@ %@", localized("transaction_label_statusDetail"), status)
        self.sharedString.append(value)
        self.addLineBreak()
        return self
    }
    
    public func add(bookingDate: String?) -> Self {
        guard let bookingDate = bookingDate else { return self }
        let value = String(format: "%@ %@", localized("transaction_label_annotationDate"), bookingDate)
        self.sharedString.append(value)
        self.addLineBreak()
        return self
    }
    
    public func add(recipient: String?) -> Self {
        guard let recipient = recipient else { return self }
        let value = String(format: "%@ %@", localized("transaction_label_recipient"), recipient)
        self.sharedString.append(value)
        self.addLineBreak()
        return self
    }
    
    public func add(accountNumber: String?) -> Self {
        guard let accountNumber = accountNumber else { return self }
        let value = String(format: "%@ %@", localized("transaction_label_cardAccountNumber"), accountNumber)
        self.sharedString.append(value)
        self.addLineBreak()
        return self
    }
    
    public func add(operationType: String?) -> Self {
        guard let operationType = operationType else { return self }
        let value = String(format: "%@ %@", localized("transaction_label_operationType"), operationType)
        self.sharedString.append(value)
        return self
    }
    
    private func addLineBreak() {
        sharedString.append("\n")
    }
    
    public func build() -> String {
        return sharedString
    }
}
