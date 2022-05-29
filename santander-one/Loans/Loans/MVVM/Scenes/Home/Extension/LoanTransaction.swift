//
//  LoanTransactionViewModel.swift
//  Loans
//
//  Created by Jose Carlos Estela Anguita on 14/10/2019.
//

import CoreFoundationLib
import CoreDomain

final class LoanTransaction {
    
    let transaction: LoanTransactionRepresentable
    var mustHideSeparationLine: Bool = false
    var mustShowBottomLineForSingleCell: Bool = false
    
    init(transaction: LoanTransactionRepresentable) {
        self.transaction = transaction
    }
    
    var date: Date {
        transaction.operationDate?.startOfDay() ?? Date().startOfDay()
    }
    
    var description: String {
        return transaction.description ?? ""
    }
    
    var amountAttributeString: NSAttributedString? {
        guard let amount = transaction.amountRepresentable else { return nil}
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20)
        let balance = MoneyDecorator(AmountEntity(amount), font: font, decimalFontSize: 16)
        return balance.getFormatedCurrency()
    }
}
