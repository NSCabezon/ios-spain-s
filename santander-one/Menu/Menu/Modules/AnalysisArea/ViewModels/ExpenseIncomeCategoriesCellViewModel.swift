//
//  ExpenseIncomeCategoriesCellViewModel.swift
//  Menu
//
//  Created by José María Jiménez Pérez on 29/6/21.
//

import Foundation

struct ExpenseIncomeCategoriesCellViewModel {
    
    let category: ExpensesIncomeCategoryType
    let percentage: String
    let amount: Decimal
    let numberOfMovements: Int
    var type: ExpensesIncomeCellType = .normal
    var isExpanded: Bool = false
    var isFirstOther: Bool = false
    
    var shouldExpand: Bool {
        return category.navigationType == .expand ? true : false
    }
    
    static var mockItems: [ExpenseIncomeCategoriesCellViewModel] =
        [ExpenseIncomeCategoriesCellViewModel(category: .atms, percentage: "18", amount: 1241.34, numberOfMovements: 4),
         ExpenseIncomeCategoriesCellViewModel(category: .banksAndInsurances, percentage: "4", amount: 231.12, numberOfMovements: 1),
         ExpenseIncomeCategoriesCellViewModel(category: .education, percentage: "6", amount: 423.47, numberOfMovements: 2),
         ExpenseIncomeCategoriesCellViewModel(category: .health, percentage: "10", amount: 5322.33, numberOfMovements: 13),
         ExpenseIncomeCategoriesCellViewModel(category: .otherExpenses, percentage: "62", amount: 6512, numberOfMovements: 4)
        ]
    static var mockOtherItems: [ExpenseIncomeCategoriesCellViewModel] =
        [ExpenseIncomeCategoriesCellViewModel(category: .helps, percentage: "30", amount: 4522, numberOfMovements: 7),
         ExpenseIncomeCategoriesCellViewModel(category: .home, percentage: "15", amount: 234, numberOfMovements: 2),
         ExpenseIncomeCategoriesCellViewModel(category: .leisure, percentage: "17", amount: 354, numberOfMovements: 3)]
    
    static func parseExpensesIncomeCategoriesViewModel(_ viewModel: ExpensesIncomeCategoriesViewModel, type: ExpensesIncomeCategoriesChartType) -> [ExpenseIncomeCategoriesCellViewModel] {
        return viewModel.getFormattedChartData(for: type).map {
            ExpenseIncomeCategoriesCellViewModel(
                category: ExpensesIncomeCategoryType(rawValue: $0.category)!,
                percentage: $0.value.asFinancialAgregatorPercentText(includePercentSimbol: false),
                amount: $0.rawValue,
                numberOfMovements: 3)
        }
    }
}

enum ExpensesIncomeCellNavigationType {
    case expand
    case detail
}

enum ExpensesIncomeCellType {
    case normal
    case otherExpanded
}
