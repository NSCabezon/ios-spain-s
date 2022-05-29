//
//  DigitalProfileElemProtocol.swift
//  CoreDomain
//
//  Created by Daniel Gómez Barroso on 24/12/21.
//

public protocol DigitalProfileElemProtocol {
    var identifier: String { get }
    func value() -> Int
    func trackName() -> String
    func desc() -> String
    func title() -> String
    func accessibilityIdentifier(state: String) -> String
}

public extension DigitalProfileElemProtocol {
    func accessibilityIdentifier(state: String) -> String {
        return ""
    }
}
