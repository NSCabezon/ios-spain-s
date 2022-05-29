//
//  AnyEquatable.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 11/22/21.
//

import Foundation
import CoreDomain

public struct AnyEquatable: Hashable {
    
    public let wrappedValue: UniqueIdentifiable
    
    public init(_ wrappedValue: UniqueIdentifiable) {
        self.wrappedValue = wrappedValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue.uniqueIdentifier)
    }
    
    public static func == (lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
