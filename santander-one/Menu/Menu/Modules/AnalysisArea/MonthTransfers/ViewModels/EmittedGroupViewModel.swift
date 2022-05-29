//
//  EmittedGroupViewModel.swift
//  Menu
//
//  Created by David Gálvez Alonso on 03/06/2020.
//

import CoreFoundationLib

final class EmittedGroupViewModel {
    let date: Date
    let dateFormatted: LocalizedStylableText
    let transfer: [TransferEmittedWithColorViewModel]
    
    init(date: Date, dateFormatted: LocalizedStylableText, transfers: [TransferEmittedWithColorViewModel]) {
        self.date = date
        self.dateFormatted = dateFormatted
        self.transfer = transfers
    }
}
