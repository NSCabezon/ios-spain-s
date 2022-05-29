//
//  EmittedGroupViewModel.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 06/04/2020.
//

import Foundation
import CoreFoundationLib
import UI

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
