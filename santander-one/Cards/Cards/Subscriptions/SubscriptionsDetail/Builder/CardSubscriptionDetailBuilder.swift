import Foundation
import CoreFoundationLib

final class CardSubscriptionDetailBuilder {
    let graphData: CardSubscriptionGraphDataEntity?
    
    init(_ graphData: CardSubscriptionGraphDataEntity? = nil) {
        self.graphData = graphData
    }
    
    func createGraphData() -> CardSubscriptionDetailGraphViewModel? {
        guard let graphData = graphData,
              let months = graphData.monthList,
              let years = graphData.yearList else { return nil }
        var yearsViewModel: [CardSubscriptionDetailYearViewModel] = []
        var summaryViewModel: [CardSubscriptionDetailSummaryViewModel] = []
        let finalMonths = removeMonthsNotNeeded(months)
        let maxExpense = calculateMaxExpense(finalMonths)
        let yearsSorted: [CardSubscriptionYearEntity] = years.sorted(by: { (year1, year2) -> Bool in
            guard let firstYear = year1.year,
                  let secondYear = year2.year else { return false }
            return firstYear < secondYear
        })
        let monthsGroupedByYear: [[CardSubscriptionMonthEntity]] = groupAndSortMonthsByYear(yearsSorted, finalMonths)
        summaryViewModel = createSummaryViewModel(years)
        yearsViewModel = createYearsViewModel(monthsGroupedByYear,
                                              yearsSorted: yearsSorted,
                                              maxExpense: maxExpense)
        return CardSubscriptionDetailGraphViewModel(yearViewModel: yearsViewModel,
                                                    summaryViewModel: summaryViewModel)
    }
    
    func getEmptyGraphData() -> CardSubscriptionDetailGraphViewModel {
        var yearsViewModel: [CardSubscriptionDetailYearViewModel] = []
        var monthList: [CardSubscriptionDetailMonthViewModel] = []
        for previousMonth in -13..<1 {
            let monthDate = Calendar.current.date(byAdding: .month, value: previousMonth, to: Date())
            monthList.append(CardSubscriptionDetailMonthViewModel(percentage: 0.0, month: "\(monthDate?.month ?? 0)", amount: AmountEntity(value: 0, currency: CoreCurrencyDefault.default)))
        }
        let year = CardSubscriptionDetailYearViewModel(monthsViewModel: monthList, maximumAverageRatio: 0)
        yearsViewModel.append(year)
        return CardSubscriptionDetailGraphViewModel(yearViewModel: yearsViewModel, summaryViewModel: nil)
    }
}

private extension CardSubscriptionDetailBuilder {
    
    func calculateMaxExpense(_ months: [CardSubscriptionMonthEntity]) -> Decimal {
        let monthWithMaximunValue = months.max { firstMonth, secondMonth -> Bool in
            guard let firstMonth = firstMonth.total.value,
                  let secondMonth = secondMonth.total.value else { return false }
            return firstMonth < secondMonth
        }
        return monthWithMaximunValue?.total.value ?? 0.0
    }
    
    func groupAndSortMonthsByYear(_ years: [CardSubscriptionYearEntity], _ months: [CardSubscriptionMonthEntity]) -> [[CardSubscriptionMonthEntity]] {
        var arrayMonths: [[CardSubscriptionMonthEntity]] = [[]]
        let yearsSortedAndCleanedUp = removePreviousYearsIfNeeded(years)
        yearsSortedAndCleanedUp.forEach { year in
            arrayMonths.append(months.filter { $0.year == year.year })
        }
        return arrayMonths
    }
    
    func removePreviousYearsIfNeeded<T>(_ summaryViewModel: [T]) -> [T] {
        var summaryLastYears = summaryViewModel
        if summaryViewModel.count > CardSubscriptionDetailGraphViewModel.numberOfYearsToShow {
            let range: Range = 0..<(summaryViewModel.count - CardSubscriptionDetailGraphViewModel.numberOfYearsToShow)
            summaryLastYears.removeSubrange(range)
        }
        return summaryLastYears
    }
    
    func createSummaryViewModel(_ model: [CardSubscriptionYearEntity]) -> [CardSubscriptionDetailSummaryViewModel] {
        var summaryViewModel = [CardSubscriptionDetailSummaryViewModel]()
        summaryViewModel = model.map { year in
            CardSubscriptionDetailSummaryViewModel(titleTotalAnnualSpent: "\(year.year ?? "")",
                                                   textTotalAnnualSpent: year.total,
                                                   titleAverageMonthlySpent: "\(year.year ?? "")",
                                                   textAverageMonthlySpent: year.avg)
        }
        return removePreviousYearsIfNeeded(summaryViewModel)
    }
    
    func createYearsViewModel(_ monthsGroupedByYear: [[CardSubscriptionMonthEntity]], yearsSorted: [CardSubscriptionYearEntity], maxExpense: Decimal) -> [CardSubscriptionDetailYearViewModel] {
        var yearsViewModel = [CardSubscriptionDetailYearViewModel]()
        let maximumExpense = maxExpense <= 0 ? 0.01 : maxExpense
        
        for year in monthsGroupedByYear {
            var monthsViewModel = [CardSubscriptionDetailMonthViewModel]()
            for month in year {
                
                let monthViewModel = CardSubscriptionDetailMonthViewModel( percentage: (month.total.value ?? 0.0) / maximumExpense,
                                                        month: month.month ?? "0",
                                                        amount: month.total )
                monthsViewModel.append(monthViewModel)
            }
            let averageForYear = yearsSorted.filter({ yearSearched -> Bool in
                yearSearched.year == year.first?.year
            }).first?.avg
            let average: CGFloat = CGFloat(NSDecimalNumber(decimal: averageForYear?.value ?? 0).doubleValue)
            let maximumExpenseFloat: CGFloat =  CGFloat(NSDecimalNumber(decimal: maximumExpense).doubleValue)
            let yearViewModel = CardSubscriptionDetailYearViewModel(monthsViewModel: monthsViewModel, maximumAverageRatio: average/maximumExpenseFloat)
            yearsViewModel.append(yearViewModel)
        }
        return yearsViewModel
    }
    
    func removeMonthsNotNeeded(_ months: [CardSubscriptionMonthEntity]) -> [CardSubscriptionMonthEntity] {
        var last13Months = months
        for _ in months where last13Months.count > 13 {
            last13Months.remove(at: 0)
        }
        return last13Months
    }
}
