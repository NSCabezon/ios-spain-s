//
//  AccountsHomePresenterModifier.swift
//  Account
//
//  Created by Rodrigo Jurado on 27/9/21.
//

import Foundation

public protocol AccountsHomePresenterModifier {
    var tagsFiltersVisibility: Bool { get }
    var hidePDFButton: Bool { get }
    var canGoToTransactionDetail: Bool { get }
    var arrowWithholdVisible: Bool { get }
    var allowOverdraft: Bool { get }
    var transactionEntryStatusAvailable: Bool { get }
}

public extension AccountsHomePresenterModifier {
    var tagsFiltersVisibility: Bool {
        false
    }
    var hidePDFButton: Bool {
        false
    }
    var canGoToTransactionDetail: Bool {
        true
    }
    var arrowWithholdVisible: Bool {
        true
    }
    var allowOverdraft: Bool {
        true
    }
    var transactionEntryStatusAvailable: Bool {
        false
    }
}
