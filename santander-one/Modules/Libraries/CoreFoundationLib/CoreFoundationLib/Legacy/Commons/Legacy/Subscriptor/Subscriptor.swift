//
//  Subscriptor.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 12/10/20.
//

import Foundation

public protocol Subscriptor: class {
    var subscriptorIdentifier: String { get }
}

extension Subscriptor {
    public var subscriptorIdentifier: String {
        return String.identifierFor(object: self)
    }
}

extension String {
    public static func identifierFor<T>(object: T) -> String {
        return "\(type(of: object))"
    }
}
