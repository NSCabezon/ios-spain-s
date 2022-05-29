import SANLegacyLibrary
import PFM
import Foundation
import CoreFoundationLib
import CoreFoundationLib

struct CardTransactionPfm {
    let cardTransactionDto: CardTransactionDTO
    
    init(cardTransaction: CardTransactionEntity) {
        self.cardTransactionDto = cardTransaction.dto
    }
    
    init(transactionModel: TransactionModel, cardTransactionModel: CardTransactionModel) {
        var transactionDto = CardTransactionDTO()
        transactionDto.operationDate = transactionModel.date
        if let currencyType = CurrencyType(rawValue: transactionModel.currency) {
            let currency = CurrencyDTO.create(currencyType)
            let decimal = Decimal(Double(transactionModel.amount)/100)
            transactionDto.amount = AmountDTO(value: decimal, currency: currency)
        }
        transactionDto.description = transactionModel.description
        transactionDto.balanceCode = cardTransactionModel.balanceCode
        transactionDto.annotationDate = transactionModel.annotationDate
        transactionDto.transactionDay = transactionModel.transactionDay
        let date = transactionModel.date.toString(format: TimeFormat.yyyyMMdd.rawValue)
        let movDay = transactionModel.transactionDay
        transactionDto.identifier = "\(date)_\(movDay)"
        self.cardTransactionDto = transactionDto
    }
    
    init(transactionModel: TransactionModel, card: CardEntity, cardTransactionModel: CardTransactionModel) {
        var transactionDto = CardTransactionDTO()
        transactionDto.operationDate = transactionModel.date
        if let currencyType = CurrencyType(rawValue: transactionModel.currency) {
            let currency = CurrencyDTO.create(currencyType)
            let decimal = Decimal(Double(transactionModel.amount)/100)
            transactionDto.amount = AmountDTO(value: decimal, currency: currency)
        }
        transactionDto.description = transactionModel.description
        transactionDto.balanceCode = cardTransactionModel.balanceCode
        transactionDto.annotationDate = transactionModel.annotationDate
        transactionDto.transactionDay = transactionModel.transactionDay
        let date = transactionModel.date.toString(format: TimeFormat.yyyyMMdd.rawValue)
        let movDay = transactionModel.transactionDay
        transactionDto.identifier = "\(date)_\(movDay)"
        self.cardTransactionDto = transactionDto
    }
    
    var transaction: CardTransactionEntity {
        return CardTransactionEntity(cardTransactionDto)
    }
    
    var pk: String {
        var pkDescription = ""
        if let operationDate = operationDate {
            pkDescription += operationDate.description
        }
        if let annotationDate = annotationDate {
            pkDescription += annotationDate.description
        }
        if let amountDto = cardTransactionDto.amount {
            let amount = AmountEntity(amountDto)
            pkDescription += amount.getFormattedPFMAmount()
        }
        if let transactionDay = transactionDay {
            pkDescription += transactionDay
        }
        if let transactionDescription = description {
            pkDescription += transactionDescription
        }
        return pkDescription
    }
    
    var operationDate: Date? {
        return cardTransactionDto.operationDate
    }
    
    var annotationDate: Date? {
        return cardTransactionDto.annotationDate
    }
    
    var transactionDay: String? {
        return cardTransactionDto.transactionDay
    }
    
    var transactionNumber: String? {
        return nil
    }
    
    var amount: Int64? {
        guard let amountDto = cardTransactionDto.amount else {
            return nil
        }
        return amountDto.value?.int64CustomValue()
    }
    
    var description: String? {
        return cardTransactionDto.description
    }
    
    var balanceCode: String? {
        return cardTransactionDto.balanceCode
    }

    var amountCurrency: String? {
        guard let currency = cardTransactionDto.amount?.currency else {
            return nil
        }
        return currency.currencyType.rawValue
    }
}

extension AmountEntity {
    
    func getFormattedPFMAmount(_ numberOfDecimals: Int = 2) -> String {
        return currencyRepresentationFor(.descriptionPFM(decimals: numberOfDecimals), value: NSDecimalNumber(decimal: dto.value ?? 0), currencySymbol: currencySymbolUI)
    }
    
    private var currencySymbolUI: String {
        let currency = CurrencyType.parse(currencyRepresentable?.currencyName)
        return currency.symbol ?? "" + currencySymbol
    }
    
    private var currencySymbol: String {
        return dto.currency?.getSymbol() ?? ""
    }
}
