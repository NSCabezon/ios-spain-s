//
//  DateTransactionGroup.swift
//  SavingProducts
//
//  Created by Jose Camallonga on 24/2/22.
//

import Foundation
import CoreDomain

typealias DateTransactionGroup = [(key: DateTransactionType, value: [SavingTransaction])]

enum DateTransactionType: Hashable {
    case completed(Date)
    case pending
}
