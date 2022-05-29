import Foundation

protocol CardTransactionPkProtocol {
    var amount: Amount { get }
    var operationDate: Date? { get }
    var transactionDay: String? { get }
}

extension CardTransactionPkProtocol {
    var pk: String {
        var pkDescription = ""
        if let date = operationDate?.description {
            pkDescription += date
        }
        pkDescription += amount.getAbsFormattedValue()
        if let currencyName = amount.currency?.currencyName {
            pkDescription += currencyName
        }
        if let transactionDay = transactionDay {
            pkDescription += transactionDay
        }
        return pkDescription
    }
}
