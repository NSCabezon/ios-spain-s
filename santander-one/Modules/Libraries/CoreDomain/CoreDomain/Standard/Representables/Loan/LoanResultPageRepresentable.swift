//
//  LoanResultPageRepresentable.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 10/26/21.
//

import Foundation

public protocol LoanResultPageRepresentable {
    var transactions: [LoanTransactionRepresentable] { get }
    var next: PaginationRepresentable? { get }
}
