import Foundation
import CoreDomain
import CoreFoundationLib
import Lottie

final class LoanTransactionDetail {
    let transaction: LoanTransactionRepresentable
    let loan: LoanRepresentable
    let transactionDetail: LoanTransactionDetailRepresentable?
    let transactionDetailConfiguration: LoanTransactionDetailConfigurationRepresentable
    let accountNumberFormatter: AccountNumberFormatterProtocol
    
    init(transaction: LoanTransactionRepresentable,
         loan: LoanRepresentable,
         transactionDetail: LoanTransactionDetailRepresentable? = nil,
         transactionDetailConfiguration: LoanTransactionDetailConfigurationRepresentable? = nil,
         accountNumberFormatter: AccountNumberFormatterProtocol) {
        self.transaction = transaction
        self.loan = loan
        self.transactionDetail = transactionDetail
        self.transactionDetailConfiguration = transactionDetailConfiguration ?? EmptyLoanTransactionDetailConfiguration()
        self.accountNumberFormatter = accountNumberFormatter
    }
    
    var title: String {
        return loan.alias ?? ""
    }
    
    var alias: String {
        return transaction.description?.capitalized ?? ""
    }
    
    var formattedAmount: NSAttributedString? {
        guard let amount = self.transaction.amountRepresentable else { return nil }
        let font = UIFont.santander(type: .bold, size: 32)
        let moneyDecorator = AmountRepresentableDecorator(amount, font: font)
        return moneyDecorator.getFormatedCurrency()
    }
    
    var operationDate: String? {
        return dateToString(date: transaction.operationDate, outputFormat: .d_MMM_yyyy)?.lowercased()
    }
        
    var annotationDate: String? {
        return dateToString(date: transaction.valueDate, outputFormat: .d_MMM_yyyy)?.lowercased()
    }
    
    var formattedCapitalAmount: String? {
        guard let amount = transactionDetail?.capitalRepresentable else { return nil }
        return AmountRepresentableDecorator(amount, font: UIFont.santander(size: 32)).getStringValue()
    }
    
    var formattedInterestAmount: String? {
        guard let amount = transactionDetail?.interestRepresentable else { return nil }
        return AmountRepresentableDecorator(amount, font: UIFont.santander(size: 32)).getStringValue()
    }
    
    var formattedFeeAmount: String? {
        guard let amount = transactionDetail?.feeRepresentable else { return nil }
        return AmountRepresentableDecorator(amount, font: UIFont.santander(size: 32)).getStringValue()
    }
    
    var formattedPendingAmount: String? {
        guard let amount = transactionDetail?.pendingAmountRepresentable else { return nil }
        return AmountRepresentableDecorator(amount, font: UIFont.santander(size: 32)).getStringValue()
    }
    
    var recipientAccountNumber: String? {
        return accountNumberFormatter.accountNumberFormat(transactionDetail?.recipientAccountNumber)
    }
    
    var recipientData: String? {
        return transactionDetail?.recipientData?.camelCasedString
    }
    
    var isTransactionNegative: Bool {
        guard let amount = transaction.amountRepresentable?.value else {
            return false
        }
        return amount < 0
    }
    
    func valueFromDetailValueField(_ field: LoanTransactionDetailValueField?) -> String? {
        guard let field = field else { return nil }
        switch field {
        case .operationDate:
            return self.operationDate
        case .valueDate:
            return self.annotationDate
        case .feeAmount:
            return self.formattedFeeAmount
        case .capitalAmount:
            return self.formattedCapitalAmount
        case .interestsAmount:
            return self.formattedInterestAmount
        case .taxes:
            return ""
        case .pendingCapitalAmount:
            return self.formattedPendingAmount
        case .recipientAccount:
            return self.recipientAccountNumber
        case .recipientData:
            return self.recipientData
        }
    }
}

extension LoanTransactionDetail: Equatable {
    static func == (lhs: LoanTransactionDetail, rhs: LoanTransactionDetail) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension LoanTransactionDetail: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.alias)
        hasher.combine(self.transaction.operationDate?.description)
        hasher.combine(self.transaction.transactionNumber)
    }
}

extension LoanTransactionDetail: Shareable {
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

private struct EmptyLoanTransactionDetailConfiguration: LoanTransactionDetailConfigurationRepresentable {
    let fields: [(LoanTransactionDetailFieldRepresentable, LoanTransactionDetailFieldRepresentable?)] = []
}
