//
//  PeriodSelectorRepresentable.swift
//  CoreDomain
//
//  Created by Jose Javier Montes Romero on 23/2/22.
//

public protocol PeriodSelectorRepresentable {
    var startPeriod: Date { get }
    var endPeriod: Date { get }
    var indexSelected: Int { get }
}
