//
//  QuickBalanceErrorViewModel.swift
//  Login
//
//  Created by Iván Estévez on 03/04/2020.
//

import Foundation
import CoreFoundationLib

struct QuickBalanceErrorViewModel {
    var errorTitle: String = ""
    var stylableErrorTitle: LocalizedStylableText?
    let errorDescription: String
    let titleButton: String
}
