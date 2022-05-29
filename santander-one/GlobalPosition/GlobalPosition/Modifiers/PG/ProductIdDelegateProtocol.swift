//
//  ProductIdDelegateProtocol.swift
//  GlobalPosition
//
//  Created by Laura González on 03/03/2021.
//

import Foundation
import CoreFoundationLib

public protocol ProductIdDelegateProtocol: AnyObject {
    func showMaskedLoanId(_ loan: LoanEntity) -> String
}
