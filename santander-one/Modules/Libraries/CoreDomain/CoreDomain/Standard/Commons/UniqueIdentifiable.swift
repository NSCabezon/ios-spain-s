//
//  UniqueIdentifiable.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 11/22/21.
//

import Foundation

public protocol UniqueIdentifiable {
    var uniqueIdentifier: Int { get }
}

func ==<T: UniqueIdentifiable>(lhs: T, rhs: T) -> Bool {
    return lhs.uniqueIdentifier == rhs.uniqueIdentifier
}
