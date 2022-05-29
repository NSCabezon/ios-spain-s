//
//  LoanTransactionDetailStringBuilder.swift
//  Account
//
//  Created by Ernesto Fernandez Calles on 30/8/21.
//

import CoreFoundationLib

final class LoanTransactionDetailStringBuilder {
    private var sharedString: String = ""
    
    func add(description: String?) -> Self {
        guard let description = description else { return self}
        self.sharedString.append("\(description)\n")
        return self
    }

    func add(alias: String?) -> Self {
        guard let alias = alias else { return self}
        self.sharedString.append("\(alias)\n")
        return self
    }
    
    func add(amount: NSAttributedString?) -> Self {
        return self.add(title: "summary_item_quantity", data: amount?.string)
    }
    
    func add(operationDate: String?) -> Self {
        return self.add(title: "transaction_label_operationDate", data: operationDate)
    }
    
    func add(bookingDate: String?) -> Self {
        return self.add(title: "transaction_label_valueDate", data: bookingDate)
    }

    func add(capitalAmount: String?) -> Self {
        return self.add(title: "transaction_label_amount", data: capitalAmount)
    }

    func add(interestAmount: String?) -> Self {
        return self.add(title: "transaction_label_interests", data: interestAmount)
    }

    func add(recipientAccountNumber: String?) -> Self {
        return self.add(title: "transaction_label_recipientAccount", data: recipientAccountNumber)
    }

    func add(recipientData: String?) -> Self {
        return self.add(title: "transaction_label_recipientData", data: recipientData)
    }

    func build() -> String {
        return self.sharedString
    }
}

private extension LoanTransactionDetailStringBuilder {
    private func add(title: String, data: String?) -> Self {
        guard let data = data else { return self }
        self.sharedString.append("\(localized(title)) \(data)\n")
        return self
    }
}
