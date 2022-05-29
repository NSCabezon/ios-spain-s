//
//  LoanNumberFormatterProtocol.swift
//  Commons
//
//  Created by José Norberto Hidalgo Romero on 17/11/21.
//

import Foundation

public protocol LoanNumberFormatterProtocol {
    func loanNumberFormat(_ entity: LoanEntity?) -> String
}
