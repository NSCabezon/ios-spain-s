//
//  DualGraphViewModel.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 18/05/2020.
//

import CoreFoundationLib
public enum BarType {
    case income
    case expense
    case predictive
    case none
}

public struct DualGraphViewModel {
    private let entity: ChartDataEntity
    private let barMaxHeightInPoints = 66.0 // altura maxima de la barra en pts
    private var barMinHeight: Double { // Si el resultado de las barras es 0€ ó <=5% se pinta un 5% de barra
        ( 5.0 * 66.0 ) / 100.0
    }
    public var disabledGraph: BarType
    public init(entity: ChartDataEntity, disabledGraph: BarType) {
        self.entity = entity
        self.disabledGraph = disabledGraph
    }
    
    public func getMaxHeightForBarType(_ barType: BarType) -> CGFloat {
        switch barType {
        case .expense:
            let expenseValue = entity.expense <= 5.0 ? barMinHeight : entity.expense
            return CGFloat((barMaxHeightInPoints * expenseValue ) / 100.0)
        case .income:
            let incomeValue = entity.income <= 5.0 ? barMinHeight : entity.income
            return CGFloat((barMaxHeightInPoints * incomeValue) / 100.0)
        case .predictive:
            let predictive = entity.predictiveExpense <= 5.0 ? barMinHeight : entity.predictiveExpense
            return CGFloat((barMaxHeightInPoints * predictive) / 100.0)
        case .none:
            return CGFloat.zero
        }
    }
}
