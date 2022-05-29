import Foundation
import CoreFoundationLib

// MARK: GraphViewModel
struct CardSubscriptionDetailGraphViewModel {
    var yearViewModel: [CardSubscriptionDetailYearViewModel]?
    var summaryViewModel: [CardSubscriptionDetailSummaryViewModel]?
    static let numberOfYearsToShow = 2
    
    init(yearViewModel: [CardSubscriptionDetailYearViewModel]? = nil, summaryViewModel: [CardSubscriptionDetailSummaryViewModel]? = nil) {
        self.yearViewModel = yearViewModel
        self.summaryViewModel = summaryViewModel
    }
}

// MARK: ViewModels used for build GraphViewModel
struct CardSubscriptionDetailYearViewModel {
    var monthsViewModel: [CardSubscriptionDetailMonthViewModel]
    var maximumAverageRatio: CGFloat
    
    init(monthsViewModel: [CardSubscriptionDetailMonthViewModel], maximumAverageRatio: CGFloat) {
        self.monthsViewModel = monthsViewModel
        self.maximumAverageRatio = maximumAverageRatio
    }
}

struct CardSubscriptionDetailMonthViewModel {
    let percentage: Decimal
    let monthTitle: String
    let amount: AmountEntity
    var isLastMonth: Bool
    
    init(percentage: Decimal, month: String, amount: AmountEntity, isLastMonth: Bool = false) {
        self.percentage = percentage
        self.monthTitle = CardSubscriptionDetailMonthViewModel.getMonth(month)
        self.amount = amount
        self.isLastMonth = isLastMonth
    }
    
    static func getMonth(_ monthNumber: String) -> String {
        let date = dateFromString(input: monthNumber, inputFormat: TimeFormat.M)
        let monthString = dateToString(date: date, outputFormat: TimeFormat.MMM)
        return monthString?.uppercased() ?? ""
    }
}

struct CardSubscriptionDetailSummaryViewModel {
    let titleTotalAnnualSpent: String
    let textTotalAnnualSpent: AmountEntity?
    let titleAverageMonthlySpent: String
    let textAverageMonthlySpent: AmountEntity?

    init(titleTotalAnnualSpent: String,
         textTotalAnnualSpent: AmountEntity?,
         titleAverageMonthlySpent: String,
         textAverageMonthlySpent: AmountEntity?) {
        self.titleTotalAnnualSpent = titleTotalAnnualSpent
        self.textTotalAnnualSpent = textTotalAnnualSpent
        self.titleAverageMonthlySpent = titleAverageMonthlySpent
        self.textAverageMonthlySpent = textAverageMonthlySpent
    }
}
