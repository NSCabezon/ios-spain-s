//
//  GeneralBudgetPage.swift
//  PersonalArea
//
//  Created by Iván Estévez on 09/06/2020.
//

import Foundation
import CoreFoundationLib

struct GeneralBudgetPage: PageWithActionTrackable {
    typealias ActionType = Action
    
    let page = "/personal_area/global_position/configuration/budget"
    
    enum Action: String {
        case slide = "slide_monthly_balance"
        case save = "save_changes"
    }
}
