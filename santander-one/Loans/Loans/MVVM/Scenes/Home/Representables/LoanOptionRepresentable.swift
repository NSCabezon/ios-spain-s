//
//  LoanOptionRepresentable.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 10/8/21.
//

import Foundation
import CoreFoundationLib
import CoreDomain

public enum LoanOptionType {
    case repayment
    case changeLoanLinkedAccount
    case detail
    case custom(identifier: String)
}

public protocol LoanOptionRepresentable: UniqueIdentifiable {
    var title: String { get }
    var imageName: String { get }
    var accessibilityIdentifier: String { get }
    var type: LoanOptionType { get }
    var titleIdentifier: String? { get }
    var imageIdentifier: String? { get }
}

public extension LoanOptionRepresentable {
    var uniqueIdentifier: Int {
        var hasher = Hasher()
        hasher.combine(title)
        hasher.combine(imageName)
        return hasher.finalize()
    }
}
