//
//  EditBudgetEntity.swift
//  Models
//
//  Created by David Gálvez Alonso on 16/03/2020.
//

public struct EditBudgetEntity {
    public let minimum: Int
    public let maximum: Int
    public let budget: Int
    public let rangeValue: Int
    
    public init(minimum: Int, maximum: Int, budget: Int, rangeValue: Int) {
        self.minimum = minimum
        self.maximum = maximum
        self.budget = budget
        self.rangeValue = rangeValue
    }
}
