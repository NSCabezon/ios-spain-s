//
//  ExpensesAnalysisConstants.swift
//  Menu
//
//  Created by José María Jiménez Pérez on 8/6/21.
//

import CoreFoundationLib

struct ExpensesAnalysisPage: PageWithActionTrackable {
    typealias ActionType = Action
    
    let page = "/analysis/expenses/"
    
    enum Action: String {
        case selectIncome = "open_income"
        case selectExpenses = "open_expenses"
        case swipeExpenses = "view_expenses"
        case swipeBuyings = "view_payments_or_purchases"
        case addOtherBank = "add_other_bank"
        case addOtherBankCarrousel = "add_other_bank_carrousel"
    }
}
