//
//  ContextSelectorModifierProtocol.swift
//  GlobalPosition
//

import Foundation

public protocol ContextSelectorModifierProtocol {
    var isContextSelectorEnabled: Bool { get }
    var showContextSelector: Bool? { get }
    var contextName: String? { get }
    func pressedContextSelector()
}
