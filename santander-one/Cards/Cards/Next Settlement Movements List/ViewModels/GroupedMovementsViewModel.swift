//
//  GroupedMovementsViewModel.swift
//  Cards
//
//  Created by David Gálvez Alonso on 20/10/2020.
//

import CoreFoundationLib

final class GroupedMovementsViewModel {
    let date: Date
    let movements: [NextSettlementMovementViewModel]
    
    init(date: Date, movements: [NextSettlementMovementViewModel]) {
        self.date = date
        self.movements = movements
    }
    
    var formatedDate: String {
        return movements.first?.date ?? ""
    }
}
