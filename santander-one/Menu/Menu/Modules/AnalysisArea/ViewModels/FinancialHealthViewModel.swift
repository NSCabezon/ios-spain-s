//
//  FinancialHealthViewModel.swift
//  Menu
//
//  Created by David Gálvez Alonso on 21/04/2020.
//

import CoreFoundationLib
import CoreDomain

class FinancialHealthViewModel {
    
    var financialCushion = Decimal.zero
    var investments = Decimal.zero
    var averageMonthlyExpenses: Double = 0
    var timeFinancialCushion: Double = 0
    var timeInvestment: Double = 0
    
    /// This constants are defined in the US + 1 month for literal more than 2 years
    private let maxTime = 25.0
    private let nearestNumber = 0.5

    init(months: [MonthlyBalanceRepresentable], totalAccount: Decimal, totalInvestments: Decimal) {
        setMonthlyExpenses(months)
        financialCushion = totalAccount
        investments = totalInvestments
        setTimeFinancialCushion()
        setTimeInvestment()
    }
}

private extension FinancialHealthViewModel {
    func setMonthlyExpenses(_ months: [MonthlyBalanceRepresentable]) {
        let sumMonthlyExpenses = months.map { Double(truncating: $0.expense as NSDecimalNumber) }.reduce(0, +)
        averageMonthlyExpenses = sumMonthlyExpenses / Double(months.count)
    }
    
    func setTimeFinancialCushion() {
        guard averageMonthlyExpenses != 0 else {
            timeFinancialCushion = 0
            return
        }
        
        let cushionValue = (financialCushion as NSNumber).doubleValue / averageMonthlyExpenses
        guard cushionValue <= maxTime else {
            timeFinancialCushion = maxTime
            return
        }
        
        timeFinancialCushion = round(cushionValue)
    }
    
    func setTimeInvestment() {
        guard averageMonthlyExpenses != 0 else {
            timeInvestment = 0
            return
        }
        
        let investmentValue = roundValue((investments as NSNumber).doubleValue / averageMonthlyExpenses, toNearest: nearestNumber)
        guard timeInvestment <= maxTime else {
            timeInvestment = maxTime
            return
        }
        
        timeInvestment = investmentValue
    }
    
    func roundValue(_ value: Double, toNearest: Double) -> Double {
      return round(value / toNearest) * toNearest
    }
}
