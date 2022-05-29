//
//  IncomeViewModel.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/19/20.
//

import Foundation
import CoreFoundationLib

final class IncomeViewModel {
    let income: IncomeEntity
    
    init(_ income: IncomeEntity) {
        self.income = income
    }
    
    var description: String {
        self.income.description.camelCasedString
    }
}
