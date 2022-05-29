//
//  TransferReceivedDetailViewModel.swift
//  RetailClean
//
//  Created by Carlos Gutiérrez Casado on 21/07/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib

class TransferReceivedDetailViewModel {
    let operationDate: Date?
    let amount: AmountEntity?
    let description: String?
    let balance: AmountEntity?
    let annotationDate: Date?
    let valueDate: Date?
    let transactionNumber: String?
    let transactionType: String?
    let productSubtypeCode: String?
    let pdfIndicator: String?
    let aliasAccountBeneficiary: String?
    
    init(operationDate: Date?, amount: AmountEntity?, description: String?, balance: AmountEntity?, annotationDate: Date?, valueDate: Date?, transactionNumber: String?, transactionType: String?, productSubtypeCode: String?, pdfIndicator: String?, aliasAccountBeneficiary: String?) {
        self.operationDate = operationDate
        self.amount = amount
        self.description = description
        self.balance = balance
        self.annotationDate = annotationDate
        self.valueDate = valueDate
        self.transactionNumber = transactionNumber
        self.transactionType = transactionType
        self.productSubtypeCode = productSubtypeCode
        self.pdfIndicator = pdfIndicator
        self.aliasAccountBeneficiary = aliasAccountBeneficiary
    }
    
    var transferAmount: NSAttributedString? {
        guard let amount = amount else { return nil }
        let decorator = MoneyDecorator(amount, font: .santander(family: .text, type: .bold, size: 32), decimalFontSize: 18)
        return decorator.formatAsMillions()
    }
    
    var destinationAccount: String {
        let aliasAccountBeneficiary = self.aliasAccountBeneficiary ?? ""
        let amount = self.balance?.getStringValue() ?? ""
        return aliasAccountBeneficiary + " (" + amount + ")"
    }
}

extension TransferReceivedDetailViewModel: Shareable {
    func getShareableInfo() -> String {
        return TransferReceivedDetailStringBuilder().build()
    }
}
