//
//  TimeLineViewModel.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 23/03/2020.
//

import Foundation
import CoreFoundationLib

struct TimeLineViewModel {
    private let timeLineResultEntity: TimeLineResultEntity
    public var currentMonth: String = ""

    public init(timeLineResponse: TimeLineResultEntity) {
        timeLineResultEntity = timeLineResponse
    }
    
    public func getDataForMonth(_ month: String) -> [ExpenseItem] {
        var result = [ExpenseItem]()
        if let reducedDebt = getItemSectionOfType(.reducedDebt, forMonth: month) {
            result.append(reducedDebt)
        }
        
        if let transferOut = getItemSectionOfType(.transferEmitted, forMonth: month) {
            result.append(transferOut)
        }
        
        if let transferIn = getItemSectionOfType(.transferReceived, forMonth: month) {
            result.append(transferIn)
        }
        
        if let bizumOut = getItemSectionOfType(.bizumEmitted, forMonth: month) {
            var bizumCopy = bizumOut
            bizumCopy.customSubtitle = timeLineResultEntity.bizumPhoneNumber
            result.append(bizumCopy)
        }
        
        if let bizumIn = getItemSectionOfType(.bizumReceived, forMonth: month) {
            var bizumCopy = bizumIn
            bizumCopy.customSubtitle = timeLineResultEntity.bizumPhoneNumber
            result.append(bizumCopy)
        }
        
        if let subscription = getItemSectionOfType(.subscription, forMonth: month) {
            result.append(subscription)
        }
        
        if let receipt = getItemSectionOfType(.receipt, forMonth: month) {
            result.append(receipt)
        }

        return result
    }
    
    public mutating func setCurrentMonth(_ month: String) {
        self.currentMonth = month
    }
    
    public func getOneMonthTimeLineData(_ monthDate: Date) -> TimeLineResultEntity {
        var timeLineFilteredData = self.timeLineResultEntity
        timeLineFilteredData.receipts?.removeAll {
            !isDateSameMonth(fullDate: ($0 as? TimeLineEntityConformable)?.fullDate ?? Date(), monthDate: monthDate)
        }
        timeLineFilteredData.transfersIn?.removeAll {
            !isDateSameMonth(fullDate: ($0 as? TimeLineEntityConformable)?.fullDate ?? Date(), monthDate: monthDate)
        }
        timeLineFilteredData.transfersOut?.removeAll {
            !isDateSameMonth(fullDate: ($0 as? TimeLineEntityConformable)?.fullDate ?? Date(), monthDate: monthDate)
        }
        timeLineFilteredData.transfersScheduled?.removeAll {
            !isDateSameMonth(fullDate: ($0 as? TimeLineEntityConformable)?.fullDate ?? Date(), monthDate: monthDate)
        }
        timeLineFilteredData.reducedDebt?.removeAll {
            $0.month != monthDate.monthOfYear()
        }
        timeLineFilteredData.subscriptions?.removeAll {
            !isDateSameMonth(fullDate: ($0 as? TimeLineEntityConformable)?.fullDate ?? Date(), monthDate: monthDate)
        }
        timeLineFilteredData.bizumsIn?.removeAll {
            !isDateSameMonth(fullDate: ($0 as? TimeLineEntityConformable)?.fullDate ?? Date(), monthDate: monthDate)
        }
        timeLineFilteredData.bizumsOut?.removeAll {
            !isDateSameMonth(fullDate: ($0 as? TimeLineEntityConformable)?.fullDate ?? Date(), monthDate: monthDate)
        }
        timeLineFilteredData.bizumPhoneNumber?.removeAll {
            !isDateSameMonth(fullDate: ($0 as? TimeLineEntityConformable)?.fullDate ?? Date(), monthDate: monthDate)
        }
        return timeLineFilteredData
    }
}

// MARK: - private methods
private extension TimeLineViewModel {
    
    /// Get the item to be returned for the specifyied month and type
    /// - Parameters:
    ///   - type: type of transaction
    ///   - month: month of the transaction, ej "01" - January
    func getItemSectionOfType(_ type: ExpenseType, forMonth month: String) -> ExpenseItem? {
        switch type {
        case .receipt:
            if let items = timeLineResultEntity.receipts?.filter({$0.month == month}) {
                return zipTransactionsOfType(type, fromCollection: items) ?? nil
            }
        case .transferReceived:
            if let items = timeLineResultEntity.transfersIn?.filter({$0.month == month}) {
                var transfersOutCopy = items
                if let outSchedulled = getSchedulledTransferWithSignPositive(true, forMonth: month), outSchedulled.count > 0 {
                    transfersOutCopy.append(contentsOf: outSchedulled)
                }
                return zipTransactionsOfType(type, fromCollection: transfersOutCopy) ?? nil
            }
        case .transferEmitted:
            if let items = timeLineResultEntity.transfersOut?.filter({$0.month == month}) {
                var transfersOutCopy = items
                if let outSchedulled = getSchedulledTransferWithSignPositive(false, forMonth: month), outSchedulled.count > 0 {
                    transfersOutCopy.append(contentsOf: outSchedulled)
                }
                return zipTransactionsOfType(type, fromCollection: transfersOutCopy) ?? nil
            }
        case .reducedDebt:
            if let items = timeLineResultEntity.reducedDebt?.filter({$0.month == month}), items.count != 0 {
                let sum = items.flatMap({$0.amount}).reduce(0, +)
                let item = ExpenseItem(expenseType: type, count: 0, amountString: formattedMoneyFromAmount(sum),
                                       issuerCount: items.count)
                return item
            }
        case .subscription:
            if let items = timeLineResultEntity.subscriptions?.filter({$0.month == month}) {
                return zipTransactionsOfType(type, fromCollection: items) ?? nil
            }
        case .bizumReceived:
            if let items = timeLineResultEntity.bizumsIn?.filter({$0.month == month}) {
                return zipTransactionsOfType(type, fromCollection: items) ?? nil
            }
        case .bizumEmitted:
            if let items = timeLineResultEntity.bizumsOut?.filter({$0.month == month}) {
                return zipTransactionsOfType(type, fromCollection: items) ?? nil
            }
        }
        return nil
    }
    
    /// return a sheduled transfer array specifying the sign of their amount value
    /// - Parameter positive: if true return schedulled transfers with positive, negative otherwise
    func getSchedulledTransferWithSignPositive(_ positive: Bool, forMonth month: String) -> [TimeLineTransfersEntity]? {
        return !positive ? timeLineResultEntity.transfersScheduled?.filter({$0.amount.isSignMinus && $0.month == month}) : timeLineResultEntity.transfersScheduled?.filter({!$0.amount.isSignMinus && $0.month == month})
    }
    /// format specified decimal value to currency
    /// - Parameter amount: decimal value
    func formattedMoneyFromAmount(_ amount: Decimal) -> NSAttributedString {
        let amountEntity = self.amountDecimalToAmountEntity(amount)
        let moneyFont = UIFont.santander(family: .text, type: .regular, size: 20)
        let decorator = MoneyDecorator(amountEntity, font: moneyFont, decimalFontSize: 16.0)
        let formmatedDecorator = decorator.formatAsMillions()
        return formmatedDecorator ?? NSAttributedString()
    }
    
    /// Convert a decimal value to an AmountEntiy
    /// - Parameter value: decimal value
    func amountDecimalToAmountEntity(_ value: Decimal) -> AmountEntity {
        return AmountEntity(value: value)
    }
    
    /// Return an entity from specified collection. After applying logic to sum all amounts and differentiate elements by merchant code the collection are zipped into one entity.
    /// - Parameters:
    ///   - transactionType: type of transaccion to scan
    ///   - collection: the collection of items of the specified type
    func zipTransactionsOfType(_ transactionType: ExpenseType, fromCollection collection: [TimeLineEntityConformable]) -> ExpenseItem? {
        let totalTransactions = collection.count
        guard totalTransactions != 0 else {
            return nil
        }
        
        let allTransactionsSum = collection.flatMap({$0.amount}).reduce(0, +)
        let issuersCodes = collection.map {$0.merchant.code}
        let uniquesIssuers = Array(Set(issuersCodes)).count
        let resultItem = ExpenseItem(expenseType: transactionType,
                                     count: totalTransactions,
                                     amountString: formattedMoneyFromAmount(allTransactionsSum),
                                     issuerCount: uniquesIssuers)
        return resultItem
    }
    
    func isDateSameMonth(fullDate: Date, monthDate: Date) -> Bool {
        return Calendar.current.isDate(fullDate, equalTo: monthDate, toGranularity: .month)
    }
}
