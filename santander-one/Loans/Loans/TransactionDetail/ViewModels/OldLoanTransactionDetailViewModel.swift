//
//  LoanTransactionDetailViewModel.swift
//  Account
//
//  Created by Ernesto Fernandez Calles on 24/8/21.
//

import CoreFoundationLib

final class OldLoanTransactionDetailViewModel {
    
    var transaction: LoanTransactionEntity
    var loan: LoanEntity
    var transactionDetail: LoanTransactionDetailEntity?
    var timeManager: TimeManager
    let dependenciesResolver: DependenciesResolver

    init(transaction: LoanTransactionEntity,
         loan: LoanEntity,
         transactionDetail: LoanTransactionDetailEntity?,
         timeManager: TimeManager,
         dependenciesResolver: DependenciesResolver) {
        self.transaction = transaction
        self.loan = loan
        self.transactionDetail = transactionDetail
        self.timeManager = timeManager
        self.dependenciesResolver = dependenciesResolver
    }
    
    var title: String {
        return loan.alias ?? ""
    }
    
    var alias: String {
        return transaction.description.capitalized
    }
    
    var formattedAmount: NSAttributedString? {
        guard let amount = transaction.amount else { return nil }
        let font = UIFont.santander(family: .text, type: .bold, size: 32)
        let moneyDecorator = MoneyDecorator(amount, font: font)
        return moneyDecorator.getFormatedCurrency()
    }
    
    var operationDate: String? {
        return timeManager.toString(date: transaction.operationDate, outputFormat: .dd_MMM_yyyy)?.lowercased()
    }
        
    var annotationDate: String? {
        return timeManager.toString(date: transaction.valueDate, outputFormat: .dd_MMM_yyyy)?.lowercased()
    }
    
    var formattedCapitalAmount: String? {
        guard let amount = transactionDetail?.capital else { return nil }
        return amount.getStringValue()
    }
    
    var formattedInterestAmount: String? {
        guard let amount = transactionDetail?.interest else { return nil }
        return amount.getStringValue()
    }
    
    var recipientAccountNumber: String? {
        guard let numberFormat = self.dependenciesResolver.resolve(forOptionalType: AccountNumberFormatterProtocol.self) else {
            return transactionDetail?.recipientAccountNumber
        }
        
        return numberFormat.accountNumberFormat(transactionDetail?.recipientAccountNumber)
    }
    
    var recipientData: String? {
        return transactionDetail?.recipientData
    }
    
    var isTransactionNegative: Bool {
        guard let amount = transaction.amount?.value else {
            return false
        }
        return amount < 0
    }
}

extension OldLoanTransactionDetailViewModel: Equatable {
    
    static func == (lhs: OldLoanTransactionDetailViewModel, rhs: OldLoanTransactionDetailViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension OldLoanTransactionDetailViewModel: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.alias)
        hasher.combine(self.transaction.operationDate?.description)
        hasher.combine(self.transaction.transactionNumber)
    }
}

private extension OldLoanTransactionDetailViewModel {
    func formattedOperationDate(date: String, time: String) -> NSAttributedString {
        let font = UIFont.santander(family: .text, type: .regular, size: 14)
        let fullText = time.isEmpty ? date : "\(date) · \(time)"
        return TextStylizer.Builder(fullText: fullText)
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: date).setStyle(font))
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: "· \(time)").setStyle(font.withSize(11)))
            .build()
    }
}

extension OldLoanTransactionDetailViewModel: Shareable {
    
    func getShareableInfo() -> String {
        return LoanTransactionDetailStringBuilder()
            .add(description: self.title)
            .add(alias: self.alias)
            .add(amount: self.formattedAmount)
            .add(operationDate: self.operationDate)
            .add(bookingDate: self.annotationDate)
            .add(capitalAmount: self.formattedCapitalAmount)
            .add(interestAmount: self.formattedInterestAmount)
            .add(recipientAccountNumber: self.recipientAccountNumber)
            .add(recipientData: self.recipientData)
            .build()
    }
}
