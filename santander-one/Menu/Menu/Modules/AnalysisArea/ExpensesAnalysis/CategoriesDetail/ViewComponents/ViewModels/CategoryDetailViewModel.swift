//
//  CategoriesDetailViewModel.swift
//  Menu
//
//  Created by David Gálvez Alonso on 01/07/2021.
//

import CoreFoundationLib
import UI

final class CategoriesDetailViewModel {
    
    let category: ExpensesIncomeCategoryType
    var details: [CategoriesDetailGroupViewModel] = []
    var timePeriodConfiguration: TimePeriodConfiguration

    var movementsNumber: Int {
        let number = details.map { (viewModel) -> Int in
            return viewModel.groupedDetails.count
        }
        return number.reduce(0, +)
    }
    
    var subcategoriesFilter: [SubcategoriesFilterViewModel] = []
    var filter: CategoryDetailFilterViewModel
    var totalAmountTimePeriods: [TimePeriodTotalAmountFilterViewModel] = []
    var periodText: String?
    var totalSpent: AmountEntity {
        // TODO Remove mock when entity is ready
        return AmountEntity(value: Decimal(floatLiteral: -1500.00), currency: CoreCurrencyDefault.default)
    }
    
    var forecastAmount: String {
        // TODO Remove mock when entity is ready
        return "-1.900€"
    }
    
    var forecastAmountValue: Decimal {
        // TODO Remove mock when entity is ready
        return 1900
    }
    
    var totalSpentMaxValue: Decimal = 0.0
    
    init(category: ExpensesIncomeCategoryType, filter: CategoryDetailFilterViewModel, timePeriodConfiguration: TimePeriodConfiguration) {
        self.category = category
        self.filter = filter
        self.timePeriodConfiguration = timePeriodConfiguration
        self.periodText = filter.timeFilter?.period
        self.addMock(filter: filter)
        self.addMockTimePeriods()
    }
    
    // TODO Remove mock when entity is ready
    func addMock(filter: CategoryDetailFilterViewModel) {
        let mock = [CategoriesDetailGroupViewModel(subcategoryColor: category.getCategoryColor())]
        mock.forEach { $0.addMock(filter: filter.filter) }
        details = mock
        let mockData = [("Todas", "1.230,00€"),
                        ("Subcategoria A", "1.345,00€"),
                        ("Subcategoria larga", "1.345,00€"),
                        ("Extra", "331.345,00€"),
                        ("Extra2", "331.345,00€"),
                        ("Extra3", "331.345,00€")
                ]
        subcategoriesFilter = mockData.map { (title, amount) -> SubcategoriesFilterViewModel in
            return SubcategoriesFilterViewModel(title: title, amount: amount, selected: (title == filter.subcategory ?? "Todas"), date: "Sep. 2021")
        }
        guard movementsNumber > 0 else {
            self.details = []
            return
        }
    }
    
    func addMockTimePeriods() {
        let mockData: [TimePeriodMockData] = getMockData()
        self.totalAmountTimePeriods = mockData.map { data -> TimePeriodTotalAmountFilterViewModel in
            return TimePeriodTotalAmountFilterViewModel(period: data.period,
                                                        amount: data.amount,
                                                        amountValue: data.value,
                                                        showForecast: data.forecast)
        }
        self.totalSpentMaxValue = self.getTotalSpentMaxValue()
    }
    
    struct TimePeriodMockData {
        let period: String
        let amount: String
        let value: Decimal
        let forecast: Bool
        
        init(_ period: String, _ amount: String, _ value: Decimal, _ forecast: Bool) {
            self.period = period
            self.amount = amount
            self.value = value
            self.forecast = forecast
        }
    }
    
    func getMockData() -> [TimePeriodMockData] {
        switch timePeriodConfiguration.type {
        case .monthly:
            let mockData: [TimePeriodMockData] = [TimePeriodMockData("Ene. 2021", "1.230,00€", 1230.0, false),
                                                  TimePeriodMockData("Feb. 2021", "1.345,00€", 1325.0, false),
                                                  TimePeriodMockData("Mar. 2021", "1.345,00€", 1345.0, false),
                                                  TimePeriodMockData("Abr. 2021", "2.345,00€", 2345.0, false),
                                                  TimePeriodMockData("May. 2021", "3.345,00€", 3345.0, false),
                                                  TimePeriodMockData("Jun. 2021", "4.345,00€", 4345.0, false),
                                                  TimePeriodMockData("Jul. 2021", "5.345,00€", 5345.0, false),
                                                  TimePeriodMockData("Ago. 2021", "6.345,00€", 6345.0, false),
                                                  TimePeriodMockData("Sep. 2021", "1.500,00€", 900.0, Date().isAfterFifteenDaysInMonth())]
            return mockData
        case .quarterly:
            let mockData: [TimePeriodMockData] = [TimePeriodMockData("Ene - Mar", "3.920,00€", 3920.00, false),
                                                  TimePeriodMockData("Abr - Jun", "10.035,00€", 10035.00, false),
                                                  TimePeriodMockData("Jul - Sep", "13.190,00€", 13190.00, false)]
            return mockData
        case .annual:
            let mockData: [TimePeriodMockData] = [TimePeriodMockData("2018", "18.230,00€", 18230.00, false),
                                                  TimePeriodMockData("2019", "21.630,00€", 21630.00, false),
                                                  TimePeriodMockData("2020", "22.830,00€", 22830.00, false),
                                                  TimePeriodMockData("2021", "27.145,00€", 27145.00, false)]
            return mockData
        default:
            let mockData: [TimePeriodMockData] = [TimePeriodMockData("Ene. 2021", "1.230,00€", 1230.0, false),
                                                  TimePeriodMockData("Feb. 2021", "1.345,00€", 1325.0, false),
                                                  TimePeriodMockData("Mar. 2021", "1.345,00€", 1345.0, false),
                                                  TimePeriodMockData("Abr. 2021", "2.345,00€", 2345.0, false),
                                                  TimePeriodMockData("May. 2021", "3.345,00€", 3345.0, false),
                                                  TimePeriodMockData("Jun. 2021", "4.345,00€", 4345.0, false),
                                                  TimePeriodMockData("Jul. 2021", "5.345,00€", 5345.0, false),
                                                  TimePeriodMockData("Ago. 2021", "6.345,00€", 6345.0, false),
                                                  TimePeriodMockData("Sep. 2021", "1.500,00€", 900.0, Date().isAfterFifteenDaysInMonth())]
            return mockData
        }
    }
    
    func totalTimePeriods() -> Int {
        self.totalAmountTimePeriods.count
    }
    
    private func getTotalSpentMaxValue() -> Decimal {
        let maxPeriod = self.totalAmountTimePeriods.compactMap { period in
            period.amountValue
        }.max() ?? 0.0
        return max(maxPeriod, forecastAmountValue)
    }
}

final class  CategoriesDetailGroupViewModel {
    var date: Date = Date()
    var groupedDetails: [CategoryDetailViewModel] = []
    let subcategoryColor: ChartSectorData.Colors
    
    init(subcategoryColor: ChartSectorData.Colors) {
        self.subcategoryColor = subcategoryColor
    }
    func setDateFormatterFiltered(_ filtered: Bool) -> LocalizedStylableText {
        let decorator = DateDecorator(self.date)
        return decorator.setDateFormatter(filtered)
    }
    
    // TODO Remove mock when entity is ready
    func addMock(filter: DetailFilter) {
        var mockDetails: [CategoryDetailViewModel] = []
        (0...5).forEach { _ in
            mockDetails.append(CategoryDetailViewModel(subcategoryColor: subcategoryColor))
        }
        groupedDetails = mockDetails.filter { (viewModel) -> Bool in
            return (viewModel.subcategory == filter.getSubcategory() || checkSubcategory(filter: filter))
                && viewModel.period == filter.getTimeFilter()?.period
        }
    }
    
    func checkSubcategory(filter: DetailFilter) -> Bool {
        // TODO Remove mock data when entity is ready
        return filter.getSubcategory() == "Todas" || filter.getSubcategory() == nil
    }
}

final class CategoryDetailViewModel {
    
    let subcategoryColor: ChartSectorData.Colors
    
    init(subcategoryColor: ChartSectorData.Colors) {
        self.subcategoryColor = subcategoryColor
    }
    
    // TODO Remove mock data when entity is ready
    var aliasDetail: String {
        return "Liquidación Períodica"
    }
    
    var idDetail: String {
        // TODO Remove mock when entity is ready
        return "382 63  3663 6363"
    }
    
    var amountDetail: NSAttributedString? {
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20)
        let amount = MoneyDecorator(AmountEntity(value: Decimal(string: "-1000.00") ?? Decimal.zero), font: font, decimalFontSize: 16)
        return amount.getFormatedCurrency()
    }
    
    var productAliasDetail: String {
        // TODO Remove mock when entity is ready
        return "Mi tarjeta Débito *3432"
    }
    
    var subcategory: String {
        // TODO Remove mock when entity is ready
        return "Subcategoria A"
    }
    
    var iconDetail: String {
        // TODO Remove mock when entity is ready
        return "icnSanSmall"
    }
    
    var period: String {
        // TODO Remove mock when entity is ready
        return "Jul. 2021"
    }
}

struct SubcategoriesFilterViewModel {
    let title: String
    let amount: String
    var selected: Bool
    let date: String
}

struct TimePeriodTotalAmountFilterViewModel {
    let period: String
    let amount: String
    let amountValue: Decimal
    let showForecast: Bool
}
