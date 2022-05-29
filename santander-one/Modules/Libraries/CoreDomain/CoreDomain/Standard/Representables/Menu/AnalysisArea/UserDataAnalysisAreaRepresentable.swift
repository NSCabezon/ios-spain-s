//
//  UserDataAnalysisAreaRepresentable.swift
//  CoreDomain
//
//  Created by Jose Javier Montes Romero on 23/2/22.
//

import Foundation

public protocol UserDataAnalysisAreaRepresentable {
    var periodSelector: PeriodSelectorRepresentable? { get }
    var timeSelector: TimeSelectorRepresentable? { get }
}
