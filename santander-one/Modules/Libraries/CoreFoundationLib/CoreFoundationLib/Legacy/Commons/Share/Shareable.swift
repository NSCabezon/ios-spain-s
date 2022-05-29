//
//  Shareable.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 12/11/19.
//

import Foundation

public protocol Shareable {
    func getRichShareableInfo() -> String
    func getShareableInfo() -> String
}

public extension Shareable {
    func getRichShareableInfo() -> String {
        return ""
    }
}
