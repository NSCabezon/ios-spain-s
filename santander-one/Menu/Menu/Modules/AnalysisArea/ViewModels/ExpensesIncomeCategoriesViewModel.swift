//
//  ExpensesIncomeCategoriesViewModel.swift
//  Menu
//
//  Created by Mario Rosales Maillo on 10/6/21.
//

import UI
import CoreFoundationLib
import UIOneComponents

enum ExpensesIncomeCategoriesChartType {
    case expenses
    case payments
    case incomes
    
    var trackerString: String {
        switch self {
        case .expenses: return "view_expenses"
        case .payments: return "view_payments_or_purchases"
        case .incomes: return "view_income"
        }
    }
    
    var suffix: String {
        switch self {
        case .expenses: return "analysis_expenses_"
        case .payments: return "analysis_payments_"
        case .incomes: return "analysis_incomes_"
        }
    }
}

public enum ExpensesIncomeCategoryType: String, CaseIterable {
    
    case education
    case transport
    case leisure
    case health
    case otherExpenses
    case helps
    case atms
    case banksAndInsurances
    case home
    case managements
    case payroll
    case purchasesAndFood
    case saving
    case taxes
    
    init?(_ categoryCode: String?) {
        guard let code = categoryCode,
              let type = (ExpensesIncomeCategoryType.allCases.first {
                  $0.matchKey.compare(code, options: .caseInsensitive) == .orderedSame }
              ) else { return nil }
        self = type
    }
    
    var literalKey: String {
        switch self {
        case .education:
            return localized("categorization_label_education")
        case .transport:
            return localized("categorization_label_transport")
        case .leisure:
            return localized("categorization_label_leisure")
        case .health:
            return localized("categorization_label_health")
        case .otherExpenses:
            return localized("categorization_label_otherExpenses")
        case .helps:
            return localized("categorization_label_helps")
        case .atms:
            return localized("categorization_label_atms")
        case .banksAndInsurances:
            return localized("categorization_label_banksAndInsurances")
        case .home:
            return localized("categorization_label_home")
        case .managements:
            return localized("categorization_label_managements")
        case .payroll:
            return localized("categorization_label_payroll")
        case .purchasesAndFood:
            return localized("categorization_label_purchasesAndFood")
        case .saving:
            return localized("categorization_label_saving")
        case .taxes:
            return localized("categorization_label_taxes")
        }
    }
    
    var matchKey: String {
        switch self {
        case .education:
            return "Educación"
        case .transport:
            return "Transporte y automoción"
        case .leisure:
            return "Ocio"
        case .health:
            return "Salud, Belleza y Bienestar"
        case .otherExpenses:
            return "Otros gastos"
        case .helps:
            return "Ayudas"
        case .atms:
            return "Cajeros y transferencias"
        case .banksAndInsurances:
            return "Bancos y seguros"
        case .home:
            return "Casa y Hogar"
        case .managements:
            return "Gestiones personales y profesionales"
        case .payroll:
            return "Nóminas"
        case .purchasesAndFood:
            return "Comercio y Tiendas"
        case .saving:
            return "Ahorro"
        case .taxes:
            return "Impuestos y tasas"
        }
    }
    
    func getChartSectorData(value: Double, rawValue: Decimal) -> ChartSectorData {
        var sector: ChartSectorData = ChartSectorData(value: value,
                                                      iconName: self.iconKey,
                                                      colors: self.getCategoryColor(),
                                                      category: self.rawValue,
                                                      rawValue: rawValue)
        sector.categoryAtttributtedText = getCategoryAttributtedText(for: sector)
        sector.categoryAtttributtedTextValue = getCategoryAttributtedTextValue(for: sector)
        return sector
    }
    
    public func getCategoryAttributtedText(for sector: ChartSectorData) -> NSAttributedString {
        let categoryText: String = localized(self.localizedKey).text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let amount = AmountEntity(value: sector.rawValue)
        let categoryAmount = amount.getFormattedAmountAsMillions(withDecimals: 2)
        let styler = TextStylizer.Builder(fullText: "\(categoryText)\n\(categoryAmount)")
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: categoryText)
                                    .setColor(sector.colors.textColor)
                                    .setStyle(UIFont.santander(family: .text, type: .bold, size: 15.0))
                                    .setParagraphStyle(paragraphStyle))
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: categoryAmount)
                                    .setColor(.lisboaGray)
                            .setStyle(UIFont.santander(family: .text, type: .bold, size: categoryAmount.count > 10 ? 20.0 : 22.0))
                                    .setParagraphStyle(paragraphStyle))
        
        if let position = categoryAmount.distanceFromStart(to: ","),
           let decimalPart = categoryAmount.substring(with: NSRange(location: position, length: categoryAmount.count - position)) {
            _ = styler.addPartStyle(part: TextStylizer.Builder.TextStyle(word: decimalPart)
                .setStyle(UIFont.santander(family: .text, type: .bold, size: 13.0)))
        }
        
        return styler.build()
    }
    
    public func getCategoryAttributtedTextValue(for sector: ChartSectorData) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        let amount = AmountEntity(value: sector.rawValue)
        let totalFinance = amount.getFormattedAmountAsMillions(withDecimals: 2)
        let styler = TextStylizer.Builder(fullText: "\(totalFinance)")
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: totalFinance)
                            .setColor(.oneLisboaGray)
                            .setStyle(.santander(family: .text, type: .bold, size: 27.0))
                            .setSize(totalFinance.count > 10 ? 20.0 : 27.0)
                            .setParagraphStyle(paragraphStyle))
        if let position = totalFinance.distanceFromStart(to: ","),
           let decimalPart = totalFinance.substring(with: NSRange(location: position, length: totalFinance.count - position)) {
            _ = styler.addPartStyle(part: TextStylizer.Builder.TextStyle(word: decimalPart)
                                        .setStyle(UIFont.santander(family: .text, type: .bold, size: 13.0)))
        }
        return styler.build()
    }
    
    public func getCategoryColor() -> ChartSectorData.Colors {
        switch self {
        case .education:
            return ChartSectorData.Colors(sector: .sanGreen, textColor: .sanGreen)
        case .transport:
            return ChartSectorData.Colors(sector: .accessibleDarkSky, textColor: .accessibleDarkSky)
        case .leisure:
            return ChartSectorData.Colors(sector: .darkBlue, textColor: .darkBlue)
        case .health:
            return ChartSectorData.Colors(sector: .darkPurple, textColor: .darkPurple)
        case .purchasesAndFood:
            return ChartSectorData.Colors(sector: .greenEmerald, textColor: .greenEmerald)
        case .home:
            return ChartSectorData.Colors(sector: .lisboaBlue, textColor: .lisboaBlue)
        case .otherExpenses:
            return ChartSectorData.Colors(sector: .brownishGray, textColor: .brownishGray)
        case .atms:
            return ChartSectorData.Colors(sector: .blueAnthracita, textColor: .blueAnthracita)
        case .managements:
            return ChartSectorData.Colors(sector: .pinkJem, textColor: .pinkJem)
        case .payroll:
            return ChartSectorData.Colors(sector: .purpleDeep, textColor: .purpleDeep)
        case .taxes:
            return ChartSectorData.Colors(sector: .bostonRed, textColor: .bostonRed)
        case .saving:
            return ChartSectorData.Colors(sector: .lightBrown, textColor: .lightBrown)
        case .banksAndInsurances:
            return ChartSectorData.Colors(sector: .pinkDeep, textColor: .pinkDeep)
        case .helps:
            return ChartSectorData.Colors(sector: .vermilion, textColor: .vermilion)
        }
    }
    
    var navigationType: ExpensesIncomeCellNavigationType {
        return self == .otherExpenses ? .expand :  .detail
    }
    
    var iconKey: String {
        switch self {
        case .otherExpenses:
            return "icnOthersCat"
        default:
            return "icn\(self.rawValue.capitalizingFirstLetter() + "Cat")"
        }
    }
    
    var localizedKey: String {
        return "categorization_label_\(self.rawValue)"
    }
    
    var accessibilityIdentifier: String {
        switch self {
        case .education: return AccesibilityExpenseIncomeCategoryType.education
        case .transport: return AccesibilityExpenseIncomeCategoryType.transport
        case .leisure: return AccesibilityExpenseIncomeCategoryType.leisure
        case .health: return AccesibilityExpenseIncomeCategoryType.health
        case .otherExpenses: return AccesibilityExpenseIncomeCategoryType.otherExpenses
        case .helps: return AccesibilityExpenseIncomeCategoryType.helps
        case .atms: return AccesibilityExpenseIncomeCategoryType.atms
        case .banksAndInsurances: return AccesibilityExpenseIncomeCategoryType.banksAndInsurances
        case .home: return AccesibilityExpenseIncomeCategoryType.home
        case .managements: return AccesibilityExpenseIncomeCategoryType.managements
        case .payroll: return AccesibilityExpenseIncomeCategoryType.payroll
        case .purchasesAndFood: return AccesibilityExpenseIncomeCategoryType.purchasesAndFood
        case .saving: return AccesibilityExpenseIncomeCategoryType.saving
        case .taxes: return AccesibilityExpenseIncomeCategoryType.taxes
        }
    }
    
    var trackerIdentifier: String {
        return self.rawValue
    }
}

class ExpensesIncomeCategoriesViewModel {
    
    private var chartSectorsData = [ChartSectorData]()
    private var otherSectorData = [ChartSectorData]()
    private let orderedSectors: [String] = [
        "banksAndInsurances",
        "home",
        "purchasesAndFood",
        "health",
        "education",
        "leisure",
        "transport",
        "atms",
        "managements",
        "taxes",
        "helps",
        "payroll",
        "saving",
        "otherExpenses"
    ]
    
    public func showDisclamerView(for type: ExpensesIncomeCategoriesChartType) -> Bool {
        switch type {
        case .expenses, .payments:
            return true
        case .incomes:
            return false
        }
    }
    
    public func getDisclaimerText(for type: ExpensesIncomeCategoriesChartType) -> LocalizedStylableText {
        switch type {
        case .incomes:
            return LocalizedStylableText(text: "", styles: nil)
        case .expenses:
            return localized("analysis_label_infoExpenses")
        case .payments:
            return localized("analysis_label_infoPurchases")
        }
    }
    
    public func getCenterAttributedTextTop(for type: ExpensesIncomeCategoriesChartType) -> NSAttributedString {
        var debtText: String = ""
        switch type {
        case .incomes:
            debtText = localized("analysis_label_totalAdmitted").text
        case .expenses:
            debtText = localized("analysis_label_totalSpent").text
        case .payments:
            debtText = localized("analysis_label_totalPaid").text
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        let styler = TextStylizer.Builder(fullText: "\(debtText)")
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: debtText)
                                .setColor(.lisboaGray)
                                .setStyle(.typography(fontName: .oneB300Regular))
                                .setSize(14.0)
                                .setParagraphStyle(paragraphStyle))
        return styler.build()
    }
    
    public func getCenterAttributedTextBottom(for type: ExpensesIncomeCategoriesChartType) -> NSAttributedString {
        loadMockData(for: type)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        let amount = getTotalAmount()
        let totalFinance = amount.getFormattedAmountAsMillions(withDecimals: 2)
        let styler = TextStylizer.Builder(fullText: "\(totalFinance)")
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: totalFinance)
                            .setBackgroundColor((type == .expenses || type == .payments ) ? .clear : UIColor(red: 228.0 / 255.0, green: 244 / 255.0, blue: 230.0 / 255.0, alpha: 1.0) )
                            .setColor(.oneBrownishGray)
                            .setStyle(UIFont.typography(fontName: .oneH300Bold))
                            .setSize(totalFinance.count > 10 ? 20.0 : 24.0)
                            .setParagraphStyle(paragraphStyle))
        if let position = totalFinance.distanceFromStart(to: ","),
           let decimalPart = totalFinance.substring(with: NSRange(location: position, length: totalFinance.count - position)) {
            _ = styler.addPartStyle(part: TextStylizer.Builder.TextStyle(word: decimalPart)
                                        .setStyle(UIFont.santander(family: .text, type: .bold, size: 13.0)))
        }
        return styler.build()
    }
    
    public func getCenterIconKey(for type: ExpensesIncomeCategoriesChartType) -> String {
        switch type {
        case .incomes:
            return "imgGasoline"
        case .expenses:
            return "imgFire"
        case .payments:
            return "oneIcnShoppingCart"
        }
    }
    
    public func getChartData(for type: ExpensesIncomeCategoriesChartType) -> [ChartSectorData] {
        chartSectorsData.removeAll()
        loadMockData(for: type)
        return chartSectorsData
    }
    
    public func getFormattedChartData(for type: ExpensesIncomeCategoriesChartType) -> [ChartSectorData] {
        chartSectorsData.removeAll()
        loadMockData(for: type)
        chartSectorsData = recalculateChartSectors(sectors: chartSectorsData)
        return chartSectorsData
    }
    
    public func getOtherSectorData() -> [ChartSectorData] {
        return self.otherSectorData
    }
}

private extension ExpensesIncomeCategoriesViewModel {
    
    func getTotalAmount() -> AmountEntity {
        let rawAmount = chartSectorsData.map { sec in sec.rawValue }.reduce(0, +)
        return AmountEntity(value: rawAmount)
    }
    
    func loadMockData(for type: ExpensesIncomeCategoriesChartType) {
        switch type {
        case .incomes:
            let values: [(type: ExpensesIncomeCategoryType, incomesValue: Double)] = [
                (.home, 4000.0),
                (.payroll, 1800.0),
                (.helps, 2000.0)
            ]
            let totalValue: Double = values.reduce(0) { $0 + $1.incomesValue }
            for value in values {
                let relativeValue = (Double(value.incomesValue / totalValue * 100))
                chartSectorsData.append(value.type.getChartSectorData(value: relativeValue, rawValue: Decimal(value.incomesValue)))
            }
            
        case .expenses:
            let values: [(type: ExpensesIncomeCategoryType, expensesValue: Double)] = [
                (.transport, 801.2),
                (.home, 39.6),
                (.taxes, 39.6),
                (.saving, 39.6),
                (.helps, 576.9),
                (.otherExpenses, 39.6),
                (.managements, 386.6),
                (.banksAndInsurances, 39.6),
                (.atms, 39.6),
                (.payroll, 39.6),
                (.education, 1057.6),
                (.purchasesAndFood, 39.6),
                (.health, 39.6),
                (.leisure, 39.6)]
            let totalValue: Double = values.reduce(0) { $0 + $1.expensesValue }
            for value in values {
                let relativeValue = (Double(value.expensesValue / totalValue * 100))
                chartSectorsData.append(value.0.getChartSectorData(value: relativeValue, rawValue: Decimal(value.1)))
            }
            
        case .payments:
            let values: [(type: ExpensesIncomeCategoryType, buyingsValue: Double)] = [
                (.transport, 88.5),
                (.leisure, 256.0),
                (.purchasesAndFood, 225.0),
                (.home, 92.0),
                (.health, 33.0),
                (.education, 33.0)
            ]
            let totalValue: Double = values.reduce(0) { $0 + $1.buyingsValue }
            for value in values {
                let relativeValue = (Double(value.buyingsValue / totalValue * 100))
                chartSectorsData.append(value.type.getChartSectorData(value: relativeValue, rawValue: Decimal(value.buyingsValue)))
            }
        }
    }
    
    func compareEqualSectors(_ sector1: ChartSectorData, _ sector2: ChartSectorData) -> Bool {
        guard let index1 = orderedSectors.firstIndex(of: sector1.category),
              let index2 = orderedSectors.firstIndex(of: sector2.category)
        else {
            return true
        }
        return index1 < index2
    }
    
    func compareSectors(_ sector1: ChartSectorData, _ sector2: ChartSectorData) -> Bool {
        if sector1.value == sector2.value {
            return compareEqualSectors(sector1, sector2)
        }
        return sector1.value > sector2.value
    }
    
    func recalculateChartSectors(sectors: [ChartSectorData]) -> [ChartSectorData] {
        let orderedSectors = sectors.sorted(by: compareSectors(_:_:))
        var newSectors: [ChartSectorData] = []
        var sectorsLowerThanTwelve: [ChartSectorData] = []
        var sectorsInOthers: [ChartSectorData] = []
        var othersRawValue: Decimal = 0
        var othersValue: Double = 0.0
        
        for sector in orderedSectors {
            if sector.value < 12 {
                sectorsLowerThanTwelve.append(sector)
                sectorsInOthers.append(sector)
                othersRawValue += sector.rawValue
                othersValue += sector.value
            } else {
                newSectors.append(sector)
            }
        }
        if sectorsLowerThanTwelve.count < 2 {
            return orderedSectors
        }
        if newSectors.isEmpty {
            sectorsInOthers.removeFirst()
            newSectors.append(sectorsLowerThanTwelve.removeFirst())
            othersValue -= newSectors[0].value
            othersRawValue -= newSectors[0].rawValue
        }
        if othersValue > 50 {
            var sectorsLowerThanTen: [ChartSectorData] = []
            othersValue = 0
            othersRawValue = 0
            sectorsInOthers.removeAll()
            for sector in sectorsLowerThanTwelve {
                if sector.value < 10 {
                    sectorsInOthers.append(sector)
                    sectorsLowerThanTen.append(sector)
                    othersRawValue += sector.rawValue
                    othersValue += sector.value
                } else {
                    newSectors.append(sector)
                }
            }
        }
        newSectors.append(ExpensesIncomeCategoryType.otherExpenses.getChartSectorData(value: othersValue,
                                                                                      rawValue: othersRawValue))
        self.otherSectorData = sectorsInOthers
        return newSectors
    }
}
