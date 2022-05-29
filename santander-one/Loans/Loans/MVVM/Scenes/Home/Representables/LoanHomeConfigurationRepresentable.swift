//
//  LoanHomeConfiguration.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 10/7/21.
//

import Foundation
import CoreDomain

public protocol LoanHomeConfigurationRepresentable {
    var loan: LoanRepresentable? { get }
}
