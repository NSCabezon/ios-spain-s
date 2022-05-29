//
//  ExpensesGraphViewModel.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 28/01/2020.
//

import Foundation
import CoreDomain
import CoreFoundationLib

typealias ExpensesParsedResults = (expenses: [MonthlyBalanceSmartPG], currentMonth: String)

final class ExpensesGraphViewModel {
    var parsedResults: ExpensesParsedResults? {
        guard let optionalPGresults = self.monthlyBalance else {
            return nil
        }
        return self.parseMontlyExpenses(optionalPGresults)
    }
    
    var isDiscreteMode: Bool = false
    
    var colorTheme: PGColorMode = .red
    var budgetSize: Float
    
    private var monthlyBalance: [MonthlyBalanceRepresentable]?
    
    init(monthlyBalance results: [MonthlyBalanceRepresentable], budgetSize: Float) {
        self.monthlyBalance = results
        self.budgetSize = budgetSize
    }
    
    private func parseMontlyExpenses(_ expenses: [MonthlyBalanceRepresentable]) -> ExpensesParsedResults {
        _ = expenses.reduce(0) { (maximum, month) -> Decimal in
            return maximum < month.expense ? month.expense : maximum
        }
        let thisMonth = dateToString(date: Date(), outputFormat: .MMM) ?? ""
        let parsedXpenses: [MonthlyBalanceSmartPG] = expenses.map {
            let month = dateToString(date: $0.date, outputFormat: .MMM) ?? ""
            let monthInfo = dateToString(date: $0.date, outputFormat: .MMMM) ?? ""
            return MonthlyBalanceSmartPG(month: month, monthInfo: monthInfo, amount: $0.expense)
        }
        return (expenses: parsedXpenses, currentMonth: thisMonth)
 
    }
}

public struct MonthlyBalanceSmartPG {
    public let month: String
    public let monthInfo: String
    public let amount: Decimal
    private var amountAsAmountEntity: AmountEntity {
        return AmountEntity(value: amount)
    }
    
    func upperCasedMonth() -> String {
        return month.uppercased()
    }
    
    func formmatedMoneyText() -> NSAttributedString? {
        let decorator = MoneyDecorator(self.amountAsAmountEntity, font: UIFont.santander(family: .text, type: .bold, size: 17))
        let deco = decorator.formatNegative(withDecimal: 0)
        return deco
    }
}
