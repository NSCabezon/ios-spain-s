//
//  SubscriptionsGroupViewModel.swift
//  Menu
//
//  Created by Laura González on 11/06/2020.
//

import CoreFoundationLib

final class SubscriptionsGroupViewModel {
    let date: Date
    let dateFormatted: LocalizedStylableText
    let subscription: [MonthSubscriptionsViewModel]
    
    init(date: Date,
         dateFormatted: LocalizedStylableText,
         subscription: [MonthSubscriptionsViewModel]) {
        self.date = date
        self.dateFormatted = dateFormatted
        self.subscription = subscription
    }
}
