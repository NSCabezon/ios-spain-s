//
//  SelectionIssueDateViewModel.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 8/2/22.
//

import Foundation

public struct SelectionIssueDateViewModel {
    public let minDate: Date
    public let maxDate: Date?
    
    public init(minDate: Date, maxDate: Date?) {
        self.minDate = minDate
        self.maxDate = maxDate
    }
}
