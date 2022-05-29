//
//  ReceiptsGroupViewModel.swift
//  Menu
//
//  Created by Ignacio González Miró on 10/06/2020.
//

import CoreFoundationLib

final class ReceiptsGroupViewModel {
    let date: Date
    let dateFormatted: LocalizedStylableText
    let receipts: [ReceiptsViewModel]
    
    init(date: Date, dateFormatted: LocalizedStylableText, receipts: [ReceiptsViewModel]) {
        self.date = date
        self.dateFormatted = dateFormatted
        self.receipts = receipts
    }
}
