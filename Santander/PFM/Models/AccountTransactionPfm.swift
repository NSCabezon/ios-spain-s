import SANLegacyLibrary
import PFM
import Foundation
import CoreFoundationLib

struct AccountTransactionPfm {
    private let transactionDto: AccountTransactionDTO
    
    init(transaction: AccountTransactionEntity) {
        self.transactionDto = transaction.dto
    }
    
    init(transactionModel: TransactionModel, account: AccountEntity, accountTransationModel: AccountTransactionModel) {
        var transactionDto = AccountTransactionDTO()
        var dgo = DGONumberDTO()
        dgo.center = accountTransationModel.center
        dgo.company = accountTransationModel.company
        dgo.number = accountTransationModel.number
        dgo.terminalCode = accountTransationModel.terminalCode
        transactionDto.dgoNumber = dgo
        transactionDto.annotationDate = transactionModel.annotationDate
        transactionDto.transactionDay = transactionModel.transactionDay
        transactionDto.transactionNumber = transactionModel.transactionNumber
        transactionDto.transactionType = transactionModel.transactionType
        transactionDto.productSubtypeCode = accountTransationModel.productSubtypeCode
        transactionDto.operationDate = transactionModel.date
        transactionDto.valueDate = transactionModel.valueDate
        transactionDto.description = transactionModel.description
        transactionDto.newContract = account.dto.contract
        if let currencyType = CurrencyType(rawValue: transactionModel.currency) {
            let currency = CurrencyDTO.create(currencyType)
            transactionDto.amount = AmountDTO(value: Decimal(Double(transactionModel.amount)/100), currency: currency)
            transactionDto.balance = AmountDTO(value: Decimal(Double(accountTransationModel.balance)/100), currency: currency)
        }
        self.transactionDto = transactionDto
    }
    
    var transaction: AccountTransactionEntity {
        return AccountTransactionEntity(transactionDto)
    }
    
    var dgo: String? {
        return "\(transactionDto.dgoNumber?.company ?? "")\(transactionDto.dgoNumber?.center ?? "")\(transactionDto.dgoNumber?.terminalCode ?? "")\(transactionDto.dgoNumber?.number ?? "")"
    }
    var terminalCode: String? {
        return transactionDto.dgoNumber?.terminalCode
    }
    var dgoNumber: String? {
        return transactionDto.dgoNumber?.number
    }
    var dgoCenter: String? {
        return transactionDto.dgoNumber?.center
    }
    var annotationDate: Date? {
        return transactionDto.annotationDate
    }
    var transactionDay: String? {
        return transactionDto.transactionDay
    }
    var transactionNumber: String? {
        return transactionDto.transactionNumber
    }
    var transactionType: String? {
        return transactionDto.transactionType
    }
    var productSubtypeCode: String? {
        return transactionDto.productSubtypeCode
    }
    var operationDate: Date? {
        return transactionDto.operationDate
    }
    var valueDate: Date? {
        return transactionDto.valueDate
    }
    var amount: Int64? {
        guard let amountDto = transactionDto.amount else {
            return nil
        }
        return amountDto.value?.int64CustomValue()
    }
    var balance: Int64? {
        guard let amountDto = transactionDto.balance else {
            return nil
        }
        return amountDto.value?.int64CustomValue()
    }
    var description: String? {
        return transactionDto.description?.trim()
    }
    var amountCurrency: String? {
        guard let currency = transactionDto.amount?.currency else {
            return nil
        }
        return currency.currencyType.rawValue
    }
}

extension Decimal {
    
    func int64CustomValue() -> Int64? {
        let number = NSNumber(value: doubleValue.doubleRounded(toPlaces: 2) * 100)
        let format = NumberFormatter()
        format.maximumFractionDigits = 2
        guard let result = format.string(from: number) else {
            return nil
        }
        return Int64(result)
    }
}
