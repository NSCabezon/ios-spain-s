//
//  AnalysisCarouselViewModel.swift
//  Menu
//
//  Created by Laura González on 24/03/2020.
//

import CoreFoundationLib
import UI
import CoreDomain

class AnalysisCarouselViewModel {
    // MARK: - Private var
    private var monthsEntity: [MonthlyBalanceRepresentable]
    private var currentMonthIndex: Int = 2
    private var pastMonthIndex: Int?
    private var percentageResumeValue: Decimal = 0.0
    private var userBudget: Double?
    
    private var currentMonthPfmEntity: MonthlyBalanceRepresentable? {
        return monthlyBalanceForIndex(currentMonthIndex)
    }
    
    private var pastMonthPfmEntity: MonthlyBalanceRepresentable? {
        guard let pastIndex = pastMonthIndex else { return nil }
        return monthlyBalanceForIndex(pastIndex)
    }
       
    // MARK: - Public var
    var percentageSavingsValue: CGFloat = 0.0
    var savingStyle: UIColor = .lightMint
               
    init(months: [MonthlyBalanceRepresentable], userBudget: Double?) {
        self.monthsEntity = months
        self.userBudget = userBudget
        self.pastMonthIndex = getPastIndex()
    }
    
    public func didSelectedCurrentMonth(_ month: Int) {
        self.currentMonthIndex = month
        self.pastMonthIndex = getPastIndex()
    }
    
    public func updateUserBudget(_ userBudget: Double) {
        self.userBudget = userBudget
    }
    
    public func getCellEntitys() -> [AnalysisCarouselViewCellModel] {
        
        var cellEntitys: [AnalysisCarouselViewCellModel] = [AnalysisCarouselViewCellModel]()
        
        cellEntitys.append(AnalysisCarouselViewCellModel(amountStyle: savingStyle,
                                                         circleValue: monthSavings,
                                                         amountText: savingsAmountText,
                                                         resumeText: savingsResumeText,
                                                         percentageValue: percentageSavingsValue,
                                                         modelType: .savings))

        if userBudget != nil {
            cellEntitys.append(AnalysisCarouselViewCellModel(amountStyle: budgetStyle,
                                                             circleValue: budgetDifference,
                                                             amountText: budgetDifference,
                                                             resumeText: budgetResumeText,
                                                             percentageValue: budgetCirclePercentage,
                                                             userBudget: budget,
                                                             modelType: .budget))
        } else {
            cellEntitys.append(AnalysisCarouselViewCellModel(amountStyle: .white,
                                                             circleValue: nil,
                                                             amountText: nil,
                                                             resumeText: nil,
                                                             modelType: .editBudget))
        }
        
        return cellEntitys
    }
    
    var budgetPercentageValue: Decimal? {
        guard let actualMonthExpense = currentMonthPfmEntity?.expense, budget != 0 else {
            if budget == 0 {
                return 100.0
            }
            return nil
        }
        return getPercentageDecimalBudget(actualMonthExpense, divider: budget)
    }
}

// MARK: - Commons functions

private extension AnalysisCarouselViewModel {
    func getPastIndex() -> Int? {
        guard self.currentMonthIndex != 0 else {
            return nil
        }
        return self.currentMonthIndex - 1
    }
    
    func monthlyBalanceForIndex(_ dataIndex: Int) -> MonthlyBalanceRepresentable? {
        let range = 0..<monthsEntity.count
        if range.contains(dataIndex) {
            return monthsEntity[dataIndex]
        }
        return nil
    }

    func decimalTruncatedToString(_ decimal: Decimal) -> String {
        let formatter = formatterForRepresentation(.decimal(decimals: 2))
        var doubleDecimal = Double(truncating: NSDecimalNumber(decimal: decimal))
        doubleDecimal = ((doubleDecimal * 100).rounded(.towardZero) / 100)
        guard let decimalToString = formatter.string(for: doubleDecimal) else {
            return ""
        }
        return decimal == 0.0 ? "0" : decimalToString
    }
    
    func decimalToString(_ decimal: Decimal) -> String {
        let formatter = formatterForRepresentation(.decimal(decimals: 0))
        var doubleDecimal = Double(truncating: NSDecimalNumber(decimal: decimal))
        doubleDecimal = ((doubleDecimal * 100).rounded(.towardZero) / 100)
        guard let decimalToString = formatter.string(for: doubleDecimal) else {
            return ""
        }
        return decimal == 0.0 ? "0" : decimalToString
    }

    func getPercentageDecimalCircle(_ amount: Decimal, divider: Decimal) -> Decimal {
        let percentage = (amount / divider) * 100
        
        if amount == 0 {
            return NSDecimalNumber(decimal: 100) as Decimal
        } else if abs(percentage) > 200 {
            return NSDecimalNumber(decimal: 100) as Decimal
        } else if abs(percentage) > 100 {
            return NSDecimalNumber(decimal: 100 - percentage) as Decimal
        } else {
            return NSDecimalNumber(decimal: percentage - 100) as Decimal
        }
    }
    
    func getPercentageText(_ value: Decimal) -> LocalizedStylableText {
        return localized("generic_label_percentage", [StringPlaceholder(.value, decimalToString(value))])
    }
}
// MARK: - Saving component

private extension AnalysisCarouselViewModel {
    var monthSavings: Decimal? {
        guard let actualIncome = currentMonthPfmEntity?.income, let actualExpense = currentMonthPfmEntity?.expense else { return nil }
        return actualIncome - actualExpense
    }
    
    var savingsAmountText: Decimal? {
        guard let actualSavings = monthSavings else { return nil }
        if actualSavings <= 0 {
            return 0
        } else {
            return actualSavings
        }
    }
    
    var savingsPercentageValue: Decimal? {
        guard let savings = monthSavings, let incomeValue = currentMonthPfmEntity?.income, incomeValue != 0 else { return 0 }
        let percentage = getPercentageDecimalSavings(savings, divider: incomeValue)
        if abs(percentage) > 100 {
            return 100.0
        }
        return percentage
    }
    
    var savingsPercentageText: LocalizedStylableText? {
        guard let percentage = savingsPercentageValue else { return nil }
        let percentageRounded = NSDecimalNumber(decimal: abs(percentage)).rounding(accordingToBehavior: nil)
        self.percentageSavingsValue = CGFloat(truncating: percentageRounded)
        return localized("generic_label_percentage", [StringPlaceholder(.value, decimalToString(percentage))])
    }
    
    var savingsResumeText: LocalizedStylableText? {
        guard
            let savings = monthSavings,
            let savingsPercentage = savingsPercentageText,
            let percentageValue = savingsPercentageValue
            else {
                return localized("analysis_label_notSaved")
        }
        let lowPercentage = getPercentageText(1.0)
        let highPercentage = getPercentageText(100.0)
        if savings <= 0 {
            return localized("analysis_label_notSaved")
        } else {
            if percentageValue < 1.0 {
                return localized("analysis_label_almostSaved", [StringPlaceholder(.value, lowPercentage.text)])
            } else if percentageValue > 99.5 && percentageValue < 100 {
                return localized("analysis_label_almostSaved", [StringPlaceholder(.value, highPercentage.text)])
            } else {
                return localized("analysis_label_incomeSaving", [StringPlaceholder(.value, savingsPercentage.text)])
            }
        }
    }
    
    func getPercentageDecimalSavings(_ amount: Decimal, divider: Decimal ) -> Decimal {
        let percentage = (amount / divider) * 100
        if amount == 0 {
            return NSDecimalNumber(decimal: 100) as Decimal
        }
        return NSDecimalNumber(decimal: percentage) as Decimal
    }
}

// MARK: - Budget component

private extension AnalysisCarouselViewModel {
    var budget: Decimal {
        guard let userBudget = self.userBudget else { return 0.0 }
        return Decimal(userBudget)
    }
    
    var budgetDifference: Decimal? {
        guard let expense = currentMonthPfmEntity?.expense else { return nil }
        return expense - budget
    }
    
    var budgetPercentageText: LocalizedStylableText? {
        guard let percentage = budgetPercentageValue else { return nil }
        return getPercentageText(abs(percentage))
    }
    
    var budgetCirclePercentage: CGFloat? {
        guard let difference = budgetDifference, let percentageValue = budgetPercentageValue else { return nil }
        let percentageRounded = NSDecimalNumber(decimal: abs(percentageValue)).rounding(accordingToBehavior: nil)
        if difference < 0 {
            return CGFloat(truncating: NSDecimalNumber(decimal: 100 - abs(percentageRounded.decimalValue)))
        } else {
            return 100.0
        }
    }
    
    var budgetResumeText: LocalizedStylableText? {
        guard let difference = budgetDifference, let percentageValue = budgetPercentageValue, let percentageText = budgetPercentageText else { return nil }
        let lowPercentage = getPercentageText(1.0)
        let highPercentage = getPercentageText(100.0)
        if budget == 0 {
            return localized("analysis_label_noBudget")
        } else if difference < 0 {
            if abs(percentageValue) < 1.0 {
                return localized("analysis_label_lessLeft", [StringPlaceholder(.value, lowPercentage.text)])
            } else if abs(percentageValue) > 99.5 && abs(percentageValue) < 100 {
                return localized("analysis_label_stillAlmost", [StringPlaceholder(.value, highPercentage.text)])
            } else {
                return localized("analysis_label_remains", [StringPlaceholder(.value, percentageText.text)])
            }
        } else if difference > 0 {
            if abs(percentageValue) < 1.0 {
                return localized("analysis_label_passed", [StringPlaceholder(.value, lowPercentage.text)])
            } else if abs(percentageValue) > 99.5 && abs(percentageValue) < 100 {
                return localized("analysis_label_almostPassed", [StringPlaceholder(.value, highPercentage.text)])
            } else {
                return localized("analysis_label_past", [StringPlaceholder(.value, percentageText.text)])
            }
        } else {
            return localized("analysis_label_budgetMet")
        }
    }
    
    var budgetStyle: UIColor {
        guard let difference = budgetDifference else { return .grafite }
        if difference < 0 {
            return .lightGrayBlue
        } else {
            return .redGraphic
        }
    }
    
    func getPercentageDecimalBudget(_ amount: Decimal, divider: Decimal) -> Decimal {
        let percentage = amount == 0 ? 100 : (divider - amount) * 100 / divider
        let percentageDecimal = NSDecimalNumber(decimal: percentage) as Decimal
        return divider > amount ? -percentageDecimal : abs(percentageDecimal)
    }
}
