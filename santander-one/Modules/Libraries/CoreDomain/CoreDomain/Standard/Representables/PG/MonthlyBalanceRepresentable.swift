//
//  MonthlyBalanceRepresentable.swift
//  CoreDomain
//
//  Created by José Carlos Estela Anguita on 9/2/22.
//

import Foundation

public protocol MonthlyBalanceRepresentable {
    var date: Date { get }
    var expense: Decimal { get }
    var income: Decimal { get }
}
