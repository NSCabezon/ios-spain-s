//
//  HeaderViewModel.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 16/03/2020.
//

import CoreFoundationLib
import CoreDomain

class HeaderViewModel {
    private var monthsEntity: [MonthlyBalanceRepresentable]
    private var headerEntities: [AnalysisHeaderEntity] = [AnalysisHeaderEntity]()
    init(months: [MonthlyBalanceRepresentable]) {
        monthsEntity = months
        compileModel()
    }
    
    /// Return the current month in the format MMMM
    var currentMonth: String? {
        let today = Date()
        return dateToString(date: today, outputFormat: .MMMM)
    }
    
    var numberOfMonths: Int {
        return headerEntities.count
    }
    
    var isPiggyBanner: Bool? 
    
    /// return the data for the given index
    /// - Parameter dataIndex: index of the data, main use is asking for thata when index change
    public func dataForIndex(_ dataIndex: Int) -> AnalysisHeaderEntity? {
        let range = 0..<headerEntities.count
        if range.contains(dataIndex) {
            return headerEntities[dataIndex]
        }
        return nil
    }
    
    /// Return last three months compiled by pfm
    public func pfmMonths() -> [String] {
        return headerEntities.map({$0.month})
    }
    
    public func monthAtIndex(_ index: Int) -> String {
        self.headerEntities[index].month
    }
    
    /// return the index of the current month on the 
    public func indexOfCurrentMonth() -> Int? {
        if let optionalMonth = currentMonth, let index = pfmMonths().firstIndex(of: optionalMonth) {
            return index
        }
        return nil
    }
    
    /// return the MonthlyBalanceRepresentable for the given index
    /// - Parameter dataIndex: index of the data, main use is asking for thata when index change
    public func monthlyBalanceForIndex(_ dataIndex: Int) -> MonthlyBalanceRepresentable? {
        let range = 0..<monthsEntity.count
        if range.contains(dataIndex) {
            return monthsEntity[dataIndex]
        }
        return nil
    }
    
    public func totalSaving() -> Decimal {
        var totalSavings: Decimal = 0
        self.monthsEntity.forEach { (monthEntity) in
            let oneMonthSavings = monthEntity.income - monthEntity.expense
            totalSavings += oneMonthSavings
        }
        return totalSavings
    }
    
    public func currentExpenses() -> Decimal? {
        let monthEntity = monthlyBalanceForIndex(2)
        return monthEntity?.expense
    }
    
    func amountDecimalToAmountEntity(_ value: Decimal) -> AmountEntity {
        return AmountEntity(value: value)
    }
}

// MARK: - Private methods
private extension HeaderViewModel {
    func compileModel() {
        var result: [AnalysisHeaderEntity] =  [AnalysisHeaderEntity]()
        _ = monthsEntity.enumerated().map({ (index, item) in
            let month = dateToString(date: item.date, outputFormat: .MMMM) ?? ""
            let incomeAttrTxt = formattedMoneyFrom(item.income, size: 26.0, decimalFont: 21.0)
            let expenseAttrTxt = formattedMoneyFrom(item.expense, negativeSign: true, size: 26.0, decimalFont: 21.0)
            let income = incomes(for: index)
            let expense = expenses(for: index)
            let predictiveExpense = predictiveExpenses(for: item)
            let chartData = ChartDataEntity(income: income, expense: expense, predictiveExpense: predictiveExpense)
            let headerEntity = AnalysisHeaderEntity(month: month, incomeText: incomeAttrTxt, expenseText: expenseAttrTxt, chartData: chartData)
            result.append(headerEntity)
        })
        headerEntities = result
    }
    
    func formattedMoneyFrom(_ amount: Decimal, negativeSign: Bool = false, size: CGFloat, decimalFont: CGFloat) -> NSAttributedString {
        var amountEntity = self.amountDecimalToAmountEntity(amount)
        if negativeSign {
            amountEntity = amountEntity.changedSign
        }
        let decorator = MoneyDecorator(amountEntity, font: UIFont.santander(family: .text, type: .bold, size: size), decimalFontSize: decimalFont)
        let formmatedDecorator = decorator.formatAsMillions()
        return formmatedDecorator ?? NSAttributedString()
    }
    
    func formattedMoneyFrom(_ amount: Decimal, negativeSign: Bool = false, size: CGFloat) -> NSAttributedString {
        var amountEntity = self.amountDecimalToAmountEntity(amount)
        if negativeSign {
            amountEntity = amountEntity.changedSign
        }
        let decorator = MoneyDecorator(amountEntity, font: UIFont.santander(family: .text, type: .bold, size: size))
        let formmatedDecorator = decorator.formatAsMillionsWithoutDecimals()
        return formmatedDecorator ?? NSAttributedString()
    }
}

private extension HeaderViewModel {
    var maxIncome: Decimal {
        let allincomes = monthsEntity.compactMap({$0.income})
        return allincomes.max() ?? 0.0
    }
    
    var maxExpense: Decimal {
        let allExpenses = monthsEntity.compactMap({$0.expense})
        return allExpenses.max() ?? 0.0
    }
    
    var maxGraphs: Decimal {
        let predictiveExpense = Decimal(self.predictiveExpenses())
        return max(maxIncome, maxExpense, predictiveExpense)
    }
    
    func incomes(for index: Int) -> Double {
        guard self.maxGraphs > 0.0 else { return 0.0 }
        let income = monthsEntity[index].income
        let calcule = income * 100 / maxGraphs
        let result = Double(truncating: NSDecimalNumber(decimal: calcule))
        return Double(round(result * 100) / 100)
    }
    
    func expenses(for index: Int) -> Double {
        guard self.maxGraphs > 0.0 else { return 0.0 }
        let expense = monthsEntity[index].expense
        let calcule = expense * 100 / maxGraphs
        let result = Double(truncating: NSDecimalNumber(decimal: calcule))
        return Double(round(result * 100) / 100)
    }
    
    func predictiveExpenses(for item: MonthlyBalanceRepresentable) -> Double {
        guard self.maxGraphs > 0.0 else { return 0.0 }
        let today = Double(Date().dayInMonth())
        let monthDays = Double(Date().numberOfDaysInMonth())
        let expense = Double(truncating: NSDecimalNumber(decimal: item.expense))
        let calcule = (expense / today) * monthDays
        let percentage = Decimal(calcule * 100) / maxGraphs
        let result = Double(truncating: NSDecimalNumber(decimal: percentage))
        let predictiveExpense = Double(round(result * 100) / 100)
        return Date().isAfterFifteenDaysInMonth() ? predictiveExpense : 0.0
    }
}

extension HeaderViewModel {
    
    public func predictiveExpenses() -> Int {
        guard isPredictiveExpense(), let item = monthsEntity.last else { return 0 }
        let todaysDay = Double(Date().dayInMonth())
        let monthDays = Double(Date().numberOfDaysInMonth())
        let expense = Double(truncating: NSDecimalNumber(decimal: item.expense))
        let predictiveExpense = round((expense / todaysDay) * monthDays)
        return Int(predictiveExpense)
    }
    
    public func isPredictiveExpense() -> Bool {
        let currentDay = Date().dayInMonth()
        return currentDay >= 15
    }
    
    public func expensePredictiveTitle() -> String {
        return localized("analysis_label_forecast")
    }
    
    public func expensePredictiveString() -> NSAttributedString {
        let predictiveExpenses = Decimal(self.predictiveExpenses())
        return self.formattedMoneyFrom(predictiveExpenses, negativeSign: true, size: 16.2)
    }
    
    public func piggyBankAmountString(decimalValue: Decimal) -> NSAttributedString {
        return self.formattedMoneyFrom(decimalValue, size: 22.0, decimalFont: 16.0)
    }
}
