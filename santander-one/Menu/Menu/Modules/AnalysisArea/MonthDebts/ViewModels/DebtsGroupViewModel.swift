//
//  DebtsGroupViewModel.swift
//  Menu
//
//  Created by Laura González on 09/06/2020.
//

import CoreFoundationLib

final class DebtsGroupViewModel {
    let date: Date
    let dateFormatted: LocalizedStylableText
    let debt: [MonthDebtsViewModel]
    
    init(date: Date,
         dateFormatted: LocalizedStylableText,
         debt: [MonthDebtsViewModel]) {
        self.date = date
        self.dateFormatted = dateFormatted
        self.debt = debt
    }
}
