//
//  TransferReceivedDetailStringBuilder.swift
//  RetailClean
//
//  Created by Carlos Gutiérrez Casado on 21/07/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib

class TransferReceivedDetailStringBuilder {
    private var sharedString: String = ""
    
    func add(transferType: String?) {
        if let transferType = transferType {
            self.sharedString.append(transferType)
            self.addLineBreak()
        }
    }
    
    func add(amount: AmountEntity?) {
        if let amount = amount {
            let value = String(format: "%@ %@", localized("summary_item_amount"), amount.getStringValue())
            self.sharedString.append(value)
            self.addLineBreak()
        }
    }
    
    func add(description: String?) {
        if let description = description {
            let value = String(format: "%@ %@", localized("summary_item_concept"), description)
            self.sharedString.append(value)
            self.addLineBreak()
        }
    }
    
    func add(aliasAccountBeneficiary: String?) {
        if let aliasAccountBeneficiary = aliasAccountBeneficiary {
            let value = String(format: "%@ %@", localized("summary_item_destinationAccounts"), aliasAccountBeneficiary)
            self.sharedString.append(value)
            self.addLineBreak()
        }
    }
    
    func add(annotationDate: Date?) {
        if let annotationDate = annotationDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            let value = String(format: "%@ %@", localized("summary_item_transactionDate"), formatter.string(from: annotationDate))
            self.sharedString.append(value)
            self.addLineBreak()
        }
    }
    
    private func addLineBreak() {
        sharedString.append("\n")
    }
    
    func build() -> String {
        return sharedString
    }
}
