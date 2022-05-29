//
//  ExpensesAnalysisConfigurationConstants.swift
//  Menu
//
//  Created by José María Jiménez Pérez on 13/7/21.
//

import CoreFoundationLib

struct ExpensesAnalysisConfigurationPage: PageWithActionTrackable {
    typealias ActionType = Action
    let page = "/analysis/expenses/configuration"
    
    enum Action: String {
        case saveChanges = "save_changes"
        case addOtherBank = "add_other_bank"
        case deleteBank = "delete_bank"
    }
}
