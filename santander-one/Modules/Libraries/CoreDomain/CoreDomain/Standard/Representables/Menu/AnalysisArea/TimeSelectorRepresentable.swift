//
//  TimeSelectorViewRepresentable.swift
//  CoreDomain
//
//  Created by Jose Javier Montes Romero on 3/2/22.
//

import Foundation

public protocol TimeSelectorRepresentable {
    var timeViewSelected: TimeViewOptions { get set }
    var startDateSelected: Date? { get set }
    var endDateSelected: Date { get set }
    func clearDates()
}

public enum TimeViewOptions: String, CaseIterable {
    case mounthly
    case quarterly
    case yearly
    case customized
}
