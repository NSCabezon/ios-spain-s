//
//  EditBudgetHelper.swift
//  Models
//
//  Created by David Gálvez Alonso on 31/03/2020.
//

import CoreDomain

public protocol EditBudgetHelperModifier {
    var maxValue: Int? { get }
    var minValue: Int? { get }
}

public protocol EditBudgetHelper: AnyObject {
    func getEditBudgetData(userBudget: Double?, threeMonthsExpenses: [MonthlyBalanceRepresentable]?, resolver: DependenciesResolver) -> EditBudgetEntity
}

public protocol BudgetBubbleViewProtocol: AnyObject {
    func didShowBudget()
    func didChangedSlide()
    func didPressSaveButton(budget: Double)
}

public extension EditBudgetHelper {
    
    func getEditBudgetData(userBudget: Double?, threeMonthsExpenses: [MonthlyBalanceRepresentable]?, resolver: DependenciesResolver) -> EditBudgetEntity {
        let modifier = resolver.resolve(forOptionalType: EditBudgetHelperModifier.self)
        guard let threeMonthsExpenses = threeMonthsExpenses, threeMonthsExpenses.isNotEmpty else {
            return getFirstCase(with: modifier)
        }
        
        let threeMonthsAmount: [Double] = threeMonthsExpenses.map { Double(truncating: $0.expense as NSDecimalNumber) }
        guard let userBudget = userBudget else {
            return getSecondCase(threeMonthsAmount: threeMonthsAmount, modifier: modifier)
        }
        return getThirdCase(userBudget: userBudget, threeMonthsAmount: threeMonthsAmount, modifier: modifier)
    }
}

// MARK: - Private methods

private extension EditBudgetHelper {
    
    // MARK: Firts case without user data and user budget
    
    func getFirstCase(with modifier: EditBudgetHelperModifier?) -> EditBudgetEntity {
        let maximum = modifier?.maxValue ?? 5000
        let minimum = modifier?.minValue ?? 0
        return EditBudgetEntity(minimum: minimum, maximum: maximum, budget: max(minimum, 1000), rangeValue: rangeValue(maximum: Double(maximum)))
    }
    
    // MARK: Second case withouth user budget

    func getSecondCase(threeMonthsAmount: [Double], modifier: EditBudgetHelperModifier?) -> EditBudgetEntity {
        let maximumDefault = Double(modifier?.maxValue ?? 5000)
        let minimumDefault = Double(modifier?.minValue ?? 1000)

        let minimumMonth = threeMonthsAmount.min() ?? 0.0
        let maximumMonth = threeMonthsAmount.max() ?? 0.0

        var minimum = minimumMonth * 0.80
        var maximum = maximumMonth * 1.20
        
        minimum = minimumMonth <= minimumDefault ? 0 : roundToNearest(value: minimum, maximum: maximumMonth)
        maximum = maximumMonth < maximumDefault ? maximumDefault : roundToNearest(value: maximum, maximum: maximumMonth)
        
        let total = threeMonthsAmount.reduce(0, +)
        let average = total / Double(threeMonthsAmount.count)
        
        return EditBudgetEntity(minimum: Int(minimum), maximum: Int(maximum), budget: max(Int(average), Int(minimum)), rangeValue: rangeValue(maximum: maximum))
    }
    
    // MARK: Third case with user data and user budget

    func getThirdCase(userBudget: Double, threeMonthsAmount: [Double], modifier: EditBudgetHelperModifier?) -> EditBudgetEntity {
        let secondCase = getSecondCase(threeMonthsAmount: threeMonthsAmount, modifier: modifier)
        
        return EditBudgetEntity(minimum: Int(secondCase.minimum), maximum: Int(secondCase.maximum), budget: Int(userBudget), rangeValue: rangeValue(maximum: Double(secondCase.maximum)))
    }
    
    func roundToNearest(value: Double, maximum: Double) -> Double {
        let powered = rangeValue(maximum: maximum)
        let intValue = Int(value)

        if powered != 0 {
            return Double(intValue - ( intValue % powered))
        } else {
            return maximum
        }
    }
    
    func rangeValue(maximum: Double) -> Int {
        let intMaximum = Int(maximum)
        let numbers: Int = String(intMaximum).count - 2
        let powered = Int(pow(10.0, Double(numbers)))
        
        return powered
    }
}
