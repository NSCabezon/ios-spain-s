//
//  SavingDetailsInfoRepresentable.swift
//  CoreDomain
//
//  Created by Marcos Álvarez Mesa on 28/4/22.
//

import Foundation

public protocol SavingDetailsInfoRepresentable {
    var type: SavingDetailElementTypeRepresentable { get }
    var action: SavingDetailElementActionRepresentable? { get }
}

public enum SavingDetailElementActionRepresentable {
    case edit
    case share
}

public enum SavingDetailElementTypeRepresentable {
    case number
    case alias
    case custom(title: String, value: String, titleIdentifier: String? = nil, valueIdentifier: String? = nil)
}

extension SavingDetailElementTypeRepresentable: Equatable {
    public static func == (lhs: SavingDetailElementTypeRepresentable, rhs: SavingDetailElementTypeRepresentable) -> Bool {
        switch (lhs, rhs) {
        case (.number, .number): return true
        case (.alias, .alias): return true
        case (let .custom(lhsTitle, lhsValue, lhsTitleIdentifier, lhsValueIdentifier), let .custom(rhsTitle, rhsValue, rhsTitleIdentifier, rhsValueIdentifier)):
            return lhsTitle == rhsTitle && lhsValue == rhsValue && lhsTitleIdentifier == rhsTitleIdentifier && lhsValueIdentifier == rhsValueIdentifier
        default: return false
        }
    }
}
